From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: DSCP values in TCP handshake
Date: Mon, 18 Apr 2011 17:57:05 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se>
References: <loom.20110418T154445-102@post.gmane.org> <1303135512.3137.335.camel@edumazet-laptop> <20110418083827.05dd2d43@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Joe Buehler <aspam@cox.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:51153 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755501Ab1DRQDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 12:03:55 -0400
In-Reply-To: <20110418083827.05dd2d43@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Apr 2011, Stephen Hemminger wrote:

> If you want to set DSCP in the response, the application needs to apply
> set it on the listening socket.
>   dscp = 0x2e;
>   setsockopt(s, IPPROTO_IP, IP_TOS, &dscp, sizeof(dscp));

<http://tools.ietf.org/html/rfc2873> says this is ok, but I would like 
default to be that if incoming SYN has a certain DSCP value, the SYN+ACK 
should mirror this value if the application doesn't explicitly set 
anything else.

I was under the impression that mirroring was done historically, but this 
has changed? Looking at how my apache server is behaving in 2.6.32, it 
seems it uses 0x0 for the whole TOS byte by default. I send it 0x20 and it 
responds with 0x0. SSH does the same thing.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
