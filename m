From: "pupilla@libero.it" <pupilla@libero.it>
Subject: per route MTU settings
Date: Fri, 11 Jan 2013 17:29:28 +0100 (CET)
Message-ID: <22271727.642511357921768466.JavaMail.defaultUser@defaultHost>
Reply-To: "pupilla@libero.it" <pupilla@libero.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outrelay01.libero.it ([212.52.84.101]:47370 "EHLO
	outrelay01.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403Ab3AKQ33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 11:29:29 -0500
Received: from wmail43 (172.31.0.232) by outrelay01.libero.it (8.5.140.03)
        id 50D43D7F026FA70F for netdev@vger.kernel.org; Fri, 11 Jan 2013 17:29:28 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody.

I have done some tests with per route
mtu settings.

Here is the results on the 10.81.104.254
linux box running 3.6.9 on Slackware 14
32bit:

ip route add 10.81.105.109/32 via 10.81.104.1 mtu lock 1450
ip route flush cache

ping -M do 10.81.105.109 -c 5 -s 1450
PING 10.81.105.109 (10.81.105.109) 1450(1478) bytes of data.
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)

Here is the results on my linux box with
ip address 10.81.104.126 (the default
gateway is 10.81.104.254) running linux
3.7.0 on Slackware 14 64bit

ping -M do 10.81.105.109 -c 5 -s 560
PING 10.81.105.109 (10.81.105.109) 560(588) bytes of data.
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 576)
>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)

When packets are generated locally (on
the 10.81.104.254 box), linux icmp message
'need to frag' report the correct mtu of
next hop. Instead on the forwarded packets
(those that aren't originated on the 10.81.104.254
box), I always get the 576 value on the mtu
of nexthop.
Is this the expected behaviour?

Any response are welcome

TIA
