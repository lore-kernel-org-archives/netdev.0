From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: forwarding pings out ingress interface
Date: Thu, 02 Jun 2011 21:46:50 +0200
Message-ID: <4DE7E8AA.20000@gmail.com>
References: <6F5DE7538AFCDA45A114F5E7510424A7027D8388@hq-exchange01.bytemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jeff Haran <jharan@bytemobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45436 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508Ab1FBTqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 15:46:55 -0400
Received: by wya21 with SMTP id 21so889136wya.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 12:46:53 -0700 (PDT)
In-Reply-To: <6F5DE7538AFCDA45A114F5E7510424A7027D8388@hq-exchange01.bytemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/06/2011 21:10, Jeff Haran a =E9crit :
> Running Redhat Enterprize 6.0, seeing the following behavior.
>
> Two Ethernet network segments: 172.30/16 and 169.254.160/24.
>
> Three "devices":
>
> [linux] is the blade running RHEL6.0. It has multiple network interfa=
ces
> and has IP forwarding enabled.
> [host] is an IP host of some sort.
> [lb] is an L3 load balancer.
>
> They are connected like so:
>
> [host] 172.30.0.254<->  172.30.0.2 [lb] 169.254.160.20<->  169.254.16=
0.1
> [linux]
>
> I have not shown the other network interfaces that [linux] is attache=
d
> to for brevity in the diagram.
>
> One of the peculiarities of [lb] is if [host] pings it at 172.30.0.2,=
 it
> will not respond to the ping itself but instead forward the ping to
> [linux]. I realize this is broken, but I have to deal with it (its
> cooked into [lb]'s silicon). [lb]'s vendor assures me that if [linux]
> would only forward the ping back to [lb] out the same interface it ca=
me
> in on, then [lb] will generate a ping response back to [host].
>
> My problem is [linux] won't forward the ping back to [lb]. [linux] ha=
s a
> route to 172.30/16 out the interface that connects it to [lb] and I c=
an
> see from tcpdump that [linux] is getting the ICMP Echo requests with
> source address 172.30.0.254 and destination address 172.30.0.2, but
> nothing gets transmitted out that interface in response.

As per RFC3927, section 2.6.2 "[a] host MUST NOT send a packet with an =
IPv4 Link-Local destination=20
address to any router for forwarding." Your linux host use 169.254.160/=
24, which is in the IPv4=20
Link-Local range. So it is normal for your linux host not to reply to a=
 ping request coming from=20
outside of the local subnet.

Why do you use an IP in the link local range? For as far as I remember =
(but I failed to find the=20
exact section), this RFC also forbid static configuration of an IP in t=
his range.

	Nicolas.
