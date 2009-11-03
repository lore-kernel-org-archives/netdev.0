From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: Avoid rounding errors for 100%.
Date: Tue, 3 Nov 2009 10:05:47 -0800
Message-ID: <20091103100547.0790ed1f@nehalam>
References: <1257262694-16985-1-git-send-email-hannemann@nets.rwth-aachen.de>
	<4AF05821.60303@nets.rwth-aachen.de>
	<20091103090752.5b462128@nehalam>
	<4AF06617.6030804@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39871 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754622AbZKCSFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 13:05:53 -0500
In-Reply-To: <4AF06617.6030804@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Nov 2009 18:19:19 +0100
Arnd Hannemann <hannemann@nets.rwth-aachen.de> wrote:

> Stephen Hemminger wrote:
> > On Tue, 03 Nov 2009 17:19:45 +0100
> > Arnd Hannemann <hannemann@nets.rwth-aachen.de> wrote:
> > 
> >> Although the patch makes sense,
> >> it does not fix the bug/effect we were seeing.
> >> A netem reorder percentage of 100% will still get packets reordered.
> >> (if the netem queue is not empty)
> >>
> >>
> >> hannemann@nets.rwth-aachen.de wrote:
> >>> From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> >>>
> >>> We noticed that a netem reorder percentage of 100% will still get packets reordered.
> >>> This patch fixes that.
> >>>
> >>> Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> >>> ---
> >>>  tc/tc_util.c |    6 ++++--
> >>>  1 files changed, 4 insertions(+), 2 deletions(-)
> >>>
> >>> diff --git a/tc/tc_util.c b/tc/tc_util.c
> >>> index fe2c7eb..2641f2e 100644
> >>> --- a/tc/tc_util.c
> >>> +++ b/tc/tc_util.c
> >>> @@ -363,8 +363,10 @@ int get_percent(__u32 *percent, const char *str)
> >>>  		return -1;
> >>>  	if (*p && strcmp(p, "%"))
> >>>  		return -1;
> >>> -
> >>> -	*percent = (unsigned) rint(per * max_percent_value);
> >>> +	if (per == 1.)
> >>> +		*percent = max_percent_value;
> >>> +	else
> >>> +		*percent = (unsigned) rint(per * max_percent_value);
> >>>  	return 0;
> >>>  }
> >>>  
> >>
> > 
> > If you don't want reordering, don't specify reordering?
> 
> Are you arguing against the correctness of my patch?
> 
> Regarding, the reordering thingy/bug/effect whatever:
> We would like to specify reordering with something like this:
> Please delay 1% of the packets with 5ms.
> 
> We thought that would be possible with
> tc qdisc add dev eth0 root netem delay 5m reorder 99%
> 
> But unfortunately it is not. Any better idea?
> 

I think the problem isn't in iproute utilities but in the code inside
netem kernel module. 

-- 
