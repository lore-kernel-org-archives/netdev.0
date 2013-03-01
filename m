From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] ipv4: correct dropwatch false positive in
 ip_local_deliver_finish
Date: Fri, 1 Mar 2013 12:12:25 -0500
Message-ID: <20130301171225.GB1523@hmsreliant.think-freely.org>
References: <1362154680-4331-1-git-send-email-nhorman@tuxdriver.com>
 <1362155912.15793.56.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	William Reich <reich@ulticom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55930 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886Ab3CARMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 12:12:32 -0500
Content-Disposition: inline
In-Reply-To: <1362155912.15793.56.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 01, 2013 at 08:38:32AM -0800, Eric Dumazet wrote:
> On Fri, 2013-03-01 at 11:18 -0500, Neil Horman wrote:
> > I had a report recently of a user trying to use dropwatch to localise some frame
> > loss, and they were getting false positives.  Turned out they were using a user
> > space SCTP stack that used raw sockets to grab frames.  When we don't have a
> > registered protocol for a given packet, we record it as a drop, even if a raw
> > socket receieves the frame.  We should only record the drop in the event a raw
> > socket doesnt exist to receive the frames
> > 
> > Tested by the reported successfully
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Reported-by: William Reich <reich@ulticom.com>
> > Tested-by: William Reich <reich@ulticom.com>
> > CC: "David S. Miller" <davem@davemloft.net>
> > CC: William Reich <reich@ulticom.com>
> > ---
> >  net/ipv4/ip_input.c | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> Hmm, could you perhaps do the similar fix for IPv6 in the same patch ?
> 
> Thanks !
> 
Sure, give me a moment, and I'll respin it.
Neil

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
