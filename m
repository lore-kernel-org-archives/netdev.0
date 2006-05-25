From: jamal <hadi@cyberus.ca>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 11:27:32 -0400
Message-ID: <1148570852.5283.23.camel@jzny2>
References: <20060523.182217.59656237.davem@davemloft.net>
	 <447412CA.50303@ipom.com> <4474A489.4080308@garzik.org>
	 <20060524185644.GF22881@ipom.com> <4474AE92.3030501@garzik.org>
	 <20060524191442.GG22881@ipom.com> <1148501433.5325.52.camel@jzny2>
	 <4474C12E.8050600@hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Phil Dibowitz <phil@ipom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:23962 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S965205AbWEYP1g
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 11:27:36 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FjHkQ-0001pF-TD
	for netdev@vger.kernel.org; Thu, 25 May 2006 11:27:38 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4474C12E.8050600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-24-05 at 13:25 -0700, Rick Jones wrote:

> The lanadmin (think ethtool) command of HP-UX has had a way to clear the 
> statistics reported by lanadmin.  I do not know however, if that affects 
> the stats in the actual SNMP interface MIBs as I've never had occasion 
> to look.
> 
> I still suggest beforeafter to people because clearing the lanadmin 
> stats requires root privs and because it may not be a kosher thing to do 
> on a customer system.
> 
> HP-UX does not provide a way to clear the stats reported by netstat.

Which also are snmp stats. 

So far the reasoning of why this is needed has been around debugging
which is in itself reasonable as long as it doesnt break things: it
does. 

For debugging: I can name about 3 ways you can achieve the counting
without touching the driver/hardware level stats. Someone needs to put
effort and create a tool to it.

[ Actually now that i spent 2 minutes looking at the patch i can
understand jgarziks concerns].

On Wed, 2006-24-05 at 16:44 -0400, Brian Haley wrote:

>So how is this different than if an SNMP station probes 
> my system,then 
> I reboot, then they probe again.  Things will seem to have gone 
> backwards, but they deal with that just fine.
> 

Rick has already answered this question i hope. There are triggers that management
tools use to identify reboots.

> DEC/Compaq/HP has allowed this on Tru64 UNIX since 1999 because we had 
> customers that wanted it, noone ever complained about complications with 
> SNMP. 

I am sure if we did things because your customer wanted it, we would approach 
anarchy at best.

>  We did save the last time the stats were zero'd in the struct for 
> posterity, but that was never get-able via SNMP:
> 

Because it is not part of the MIB i would suspect. 

> 
> --> netstat -I tu0 -s
> 
> tu0 Ethernet counters at Wed May 24 16:30:05 2006
> 
>            609415 seconds since last zeroed
>        3943458720 bytes received
>         113576310 bytes sent
> ...
> 
> Maybe saving a "ztime" would make people happier?

It may be insufficient. 
Management tools use the resetting as a trigger to indicate rollover of the 
counters. I dont know if you can go and fix everyone out there to have this
new ztime in mind.

Can you ask internally on how openview would handle this? It carriers the 
major chunk of management tools market so it may provide good insight.

On Wed, 2006-24-05 at 14:04 -0700, Rick Jones wrote: 
> Phil Dibowitz wrote:
> > Well, I can show you support on my home switch (cabletron) - the network guys
> > will be a little unhappy if I clear stats on our production network (cisco)
> > without warning them:
> 
> Isn't that last bit an example of why it might not be good to play-out 
> that rope?-)
> 

I dont mind him hanging himself, he just wants to hang us all ;->

cheers,
jamal

