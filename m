From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/4] mac80211-hwsim: Pass rate-ctrl flags and tx-power
 to user-space
Date: Fri, 17 Apr 2015 13:23:28 +0200
Message-ID: <1429269808.1885.2.camel@sipsolutions.net>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>
	  <1428095523-374-3-git-send-email-greearb@candelatech.com>
	 <1428999345.3019.9.camel@sipsolutions.net>
	 <552E909E.6010405@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:46669 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752865AbbDQLXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2015 07:23:33 -0400
In-Reply-To: <552E909E.6010405@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 09:23 -0700, Ben Greear wrote:
> On 04/14/2015 01:15 AM, Johannes Berg wrote:
> > On Fri, 2015-04-03 at 14:12 -0700, greearb@candelatech.com wrote:
> > 
> >> +/* Auxilary info to allow user-space to better understand the rate */
> >> +struct hwsim_tx_rate2 {
> >> +	u16 rc_flags; /* rate-ctrl flags (see mac80211_rate_control_flags) */
> > 
> > I really don't like this - it ties internal API to userspace API. You
> > may argue that this is userspace that is for debug purposes only, but
> > I'm sure you'll also scratch your head very confused when I change the
> > rate control flags for any reason and your code breaks :)
> 
> Is this a documentation only issue (at this point, while code matches)?

Well, technically this could be done.

> Then later, we can add translation to keep user-space API the same
> as needed?

We'll almost certainly forget that though, so better to have a
translation layer now.

OTOH though, perhaps we don't even want to advertise all these flags. We
might want to change the details of how these work, so I think it'd be
good to actually analyse them and see which ones really are needed. That
really applies more to the rx-status flags then here perhaps.

> And in that case, maybe I'll make it u32 to give room down the road?

That makes sense - netlink attributes are even 4-byte aligned so there's
no space saving with u16 either :)

johannes
