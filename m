From: Joe Buehler <aspam@cox.net>
Subject: Re: DSCP values in TCP handshake
Date: Mon, 18 Apr 2011 15:01:30 -0400
Message-ID: <4DAC8A8A.1010401@cox.net>
References: <loom.20110418T154445-102@post.gmane.org> <1303135512.3137.335.camel@edumazet-laptop> <20110418083827.05dd2d43@nehalam> <alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmfepi201.cox.net ([68.230.241.205]:41816 "EHLO
	eastrmfepi201.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756523Ab1DRTSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 15:18:03 -0400
In-Reply-To: <alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> <http://tools.ietf.org/html/rfc2873> says this is ok, but I would like
> default to be that if incoming SYN has a certain DSCP value, the SYN+ACK
> should mirror this value if the application doesn't explicitly set
> anything else.
> 
> I was under the impression that mirroring was done historically, but
> this has changed? Looking at how my apache server is behaving in 2.6.32,
> it seems it uses 0x0 for the whole TOS byte by default. I send it 0x20
> and it responds with 0x0. SSH does the same thing.

In my case I just need the SYN-ACK to reflect the incoming SYN.  To get
it I am going to use iptables like so (barring bugs on my part -- still
testing this...):

iptables -t mangle -A PREROUTING -m tcp -p tcp --tcp-flags SYN,RST,ACK
SYN -m dscp --dscp 0 -j CONNMARK --set-mark 0
iptables -t mangle -A POSTROUTING -m tcp -p tcp --tcp-flags SYN,RST,ACK
SYN,ACK -m connmark --mark 0 -j DSCP --set-dscp 0
(repeat for the other 63 values of DSCP...)

The argument I have seen for not making reflection standard behavior is
that it is not always appropriate for the application.  For example, web
servers have short requests but large responses so non-identical DSCP
values might make more sense.

Thanks for all the replies.

Joe Buehler
