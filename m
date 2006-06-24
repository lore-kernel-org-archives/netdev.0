From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Sat, 24 Jun 2006 10:39:57 -0400
Message-ID: <1151159997.6716.116.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>  <4497474C.4050706@trash.net>
	 <1150815375.5270.78.camel@jzny2>  <44980FA3.1000009@trash.net>
	 <1151001712.5392.47.camel@jzny2>  <449BFB82.9000008@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, hawk@diku.dk,
	russell-tcatm@stuart.id.au, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:20155 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750788AbWFXOkA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jun 2006 10:40:00 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fu9Ip-00011I-Q2
	for netdev@vger.kernel.org; Sat, 24 Jun 2006 10:40:03 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <449BFB82.9000008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-23-06 at 16:32 +0200, Patrick McHardy wrote:
> jamal wrote:

> > If you do it in user space you will need a daemon of some form; this is
> > my preference but it seems a lot of people hate daemons - the standard
> > claim is it is counter-usability. Such people are forgiving if you built
> > the daemon into the kernel as a thread. Perhaps the netcarrier that
> > Stefan Rompf has added could be extended to handle this)
> 
> I absolutely disagree, in my opinion we currently have too few
> specialized daemons and a lot too much wild shell scripting with
> seding, awking, grepping. 

Like i said i too prefer a daemon; but i have experienced a lot of
people who dont (especially in small embedded devices).

> I'm actually working on a daemon that
> provides a small scripting language to express networking configuration
> states and react to result set changes and state transitions.
> Its far from complete, but already allows you to express things like
> "on transition from { none, link flags !up } to { link flags up }
> execute /etc/network/link/$LINK_NAME up" (same for routes, addresses,
> basically all object types) or "for each link with flags lowerup,up
> execute add-to-bridge.sh". The value of each expression is dumped
> into the environment on execution, so you can comfortably use
> $LINK_NAME or $LINK_MTU instead of having to cut it out the
> "ip link list" output. Should be trivial to support link speed changes
> once we have notifications for that.
> 

cool - a neteventd


> I don't think it should carry both old and new speed. Netlink
> notifications usually provide a snapshot of the new state, but
> no indication what changed, with one notable exception, the
> ifi_change field, which IMO is a hack for lazy userspace. 

I am quiet fond of the ifi_change ;->

> Since
> notifications can get lost, userspace needs to resync occasionally.
> The naiive approach (works for every other object) to determine if
> the object state changed from my last known state is to compare
> all attributes ..

scalability issues abound when you have a gazillion things to look at.
There used or may still be a way to tell from looking at netlink socket
that an error occurred since last time - such as "a message was lost".
You could use that to tell a message was lost and do scanning only
then.  

>  but the ifi_change field will be different
> between notifications and dumps even if the object itself didn't
> change. "Lazy userspace" because looking at ifi_change is obviously
> only useful if it doesn't keep its last known state and tries to
> derive the change from update notifications alone .. which means it
> fails when notifications are lost.
> 

But thats not the real intent for it. 

cheers,
jamal

PS:- I will look at your other postings and respond later i have to run
for now.

