From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: per route MTU settings
Date: Fri, 11 Jan 2013 19:35:45 +0100
Message-ID: <DUB107-W16D4CBDC18DD7256153ED7ED290@phx.gbl>
References: <22271727.642511357921768466.JavaMail.defaultUser@defaultHost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <pupilla@libero.it>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [157.55.0.218] ([157.55.0.218]:19714 "EHLO
	dub0-omc1-s19.dub0.hotmail.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753510Ab3AKSgH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 13:36:07 -0500
In-Reply-To: <22271727.642511357921768466.JavaMail.defaultUser@defaultHost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

10.81.104.254 will never transmit anything with
> ping -M do 10.81.105.109 -c 5 -s 1450
because the host already knows a 1478 Byte packet won't fit the
1450 Byte route you made towards 10.81.104.1.

You do realize that 1450 is your ICMP payload, plus ICMP header (8B)
and IP header (20B) and you are at 1478B, which exceeds your route's
MTU.


I guess 10.81.104.1 has a 576B MTU route/interface towards
10.81.105.109, and you did the first test on 10.81.104.254,
and only afterwards you tried "-s 560" from .126, so only
then the .254 host realized the transport to 10.81.104.1
is actually a 576B MTU path.

You cannot do pings with 2 different packet sizes on 2 different hosts,
and expect them to behave exactly the same.

Running from both hosts pings with:
-s 548
-s 549
-s 1422
-s 1423

and then analyzing the results will probably give us a better
idea of what actually happens.



Regards,

Lukas





----------------------------------------
> Date: Fri, 11 Jan 2013 17:29:28 +0100
> From: pupilla@libero.it
> To: netdev@vger.kernel.org
> Subject: per route MTU settings
>
> Hello everybody.
>
> I have done some tests with per route
> mtu settings.
>
> Here is the results on the 10.81.104.254
> linux box running 3.6.9 on Slackware 14
> 32bit:
>
> ip route add 10.81.105.109/32 via 10.81.104.1 mtu lock 1450
> ip route flush cache
>
> ping -M do 10.81.105.109 -c 5 -s 1450
> PING 10.81.105.109 (10.81.105.109) 1450(1478) bytes of data.
> From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
> From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
> From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
> From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
> From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
>
> Here is the results on my linux box with
> ip address 10.81.104.126 (the default
> gateway is 10.81.104.254) running linux
> 3.7.0 on Slackware 14 64bit
>
> ping -M do 10.81.105.109 -c 5 -s 560
> PING 10.81.105.109 (10.81.105.109) 560(588) bytes of data.
> From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 576)
> From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
> From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
> From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
> From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
>
> When packets are generated locally (on
> the 10.81.104.254 box), linux icmp message
> 'need to frag' report the correct mtu of
> next hop. Instead on the forwarded packets
> (those that aren't originated on the 10.81.104.254
> box), I always get the 576 value on the mtu
> of nexthop.
> Is this the expected behaviour?
>
> Any response are welcome
>
> TIA
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
 		 	   		  