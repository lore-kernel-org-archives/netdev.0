From: Milan Dadok <milan@dadok.name>
Subject: RE: [PATCH] 1/1 net: packet: Keep 802.1Q VLAN tag in packet on SOCK_DGRAM socket - resend
Date: Mon, 4 Jan 2010 16:28:03 +0100
Message-ID: <001b01ca8d52$817d07d0$84771770$@name>
References: <001801ca8d1d$90c68de0$b253a9a0$@name> <4B41F292.8080908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <uaca@alumni.uv.es>, <johann.baudy@gnu-log.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: 'Patrick McHardy' <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.kvados.cz ([194.213.53.146]:34848 "EHLO mailgw.kvados.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752601Ab0ADP2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 10:28:08 -0500
In-Reply-To: <4B41F292.8080908@trash.net>
Content-Language: cs
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:

>Milan Dadok wrote:
>> Keep 802.1Q VLAN tag on non HW vlan accelerated network card received to SOCK_DGRAM socket.

>So not including the link layer header for SOCK_DGRAM sockets
>seems to be the intended behaviour.

>From my point of view i have question
Is 802.1Q encapsulation (or another type of encapsulation (IPSec?)) part of link level header or part of data packet?

Currently pseudo-header contains for OUTGOING packet on physical card (vlan10@eth1)
a) HW accelarated network card  
protocol = ethertype IPv4 (0x0800)
tci = vlan number = 10
and data starts with 4500 0028

b) non HW accelerated network card 
protocol = ethertype 802.1Q (0x8100)
tci = 0
and data starts with 4500 0028
vlan tci and real protocol number (ARP,IPV4,IPV6) of data is lost 

And with more nested vlans it is getting worse
for example

vlan1010@vlan10@eth1

a) HW accelarated network card  
protocol = ethertype IPv4 (0x8100)
tci = 10
and data starts with 4500 0028

the 4 bytes of real packet 03f2 0800 is lost too

b) non HW accelarated network card  
4 words of data packet are lost ...

I have no problems with received packets, only outgoing packet have problem.
I think that out packet on SOCK_DGRAM sockets MUST BE in same format as in (received) packet on same interface.
Can we agree on this?

Milan



