From: Dan Williams <dcbw@redhat.com>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Thu, 21 Jul 2011 11:35:37 -0500
Message-ID: <1311266139.3059.9.camel@dcbw.foobar.com>
References: <20110719180222.GA7509@midget.suse.cz>
	 <1311178905.21004.9.camel@dcbw.foobar.com>
	 <20110720163656.GD11692@midget.suse.cz>
	 <1311226254.3140.52.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	stephen hemminger <shemminger@vyatta.com>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45503 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949Ab1GURPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 13:15:53 -0400
In-Reply-To: <1311226254.3140.52.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-21 at 00:30 -0500, Dan Williams wrote:
> On Wed, 2011-07-20 at 18:36 +0200, Jiri Bohac wrote:
> > On Wed, Jul 20, 2011 at 11:21:43AM -0500, Dan Williams wrote:
> > > ... and in the resume handler use that value to age anything
> > > that needs to know about time spent in suspend, and then do what needs
> > > to be done with that.  So something like that may work for IPv6
> > > addrconf; on suspend save current time, and on resume check the current
> > > time, subtract the time you saved on suspend, and magically add that to
> > > the lifetime counts and then run any expiry stuff.
> > 
> > IPv6 (by specification) does not send any RS when an IP address
> > or route expires. So only subtracting the supend time from the
> > lifetimes and possibly expiring the routes/IP addresses won't fix
> > the problem.
> 
> Well, the prefix option of the RA includes the Valid Lifetime (in
> seconds, no less) so I'd assume the kernel starts a timer when it
> receives the RA and updates any addresses configured as a result of
> receiving that RA+prefix, such that when the timer expires, the
> autoconfigured address is deleted.  That timer can be used as a base for
> the expiry mechanism that I've noted above, no?  This fixes problem #1
> from your first mail.
> 
> For problem #2, shouldn't a new RS be sent whenever the interface
> changes it's IFF_LOWER_UP bit?  IFF_LOWER_UP indicates a carrier on/off
> event and thus indicates possible disconnect/reconnect to a new network.
> I don't specifically know how it works now, but if RS isn't triggered
> from IFF_LOWER_UP, I'd imagine that either (a) something didn't get
> updated when IFF_LOWER_UP became how carrier was indicated in 2.6.17
> (commit b00055aacdb172c05067612278ba27265fcd05ce) or (b) there's a
> reason IFF_LOWER_UP isn't used as the trigger for sending an RS and I'm
> qualified to say why.

Should be "I'm not qualified to say why".

> Dan
> 
> > When I move to a new network, I need to restart the
> > autoconfiguration. This does not currently happen - neither for
> > an alive system where the ethernet link goes down/up, nor for a
> > system that gets suspended, moved and then resumed.
> > 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


