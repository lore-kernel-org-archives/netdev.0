From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Link-local address handling for IPv4
Date: Tue, 22 Jun 2010 19:21:35 +0200
Message-ID: <1277227295.3057.697.camel@edumazet-laptop>
References: <0199E0D51A61344794750DC57738F58E739702DDAE@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40299 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756697Ab0FVRVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 13:21:39 -0400
Received: by mail-wy0-f174.google.com with SMTP id 11so50906wyi.19
        for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 10:21:38 -0700 (PDT)
In-Reply-To: <0199E0D51A61344794750DC57738F58E739702DDAE@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 juin 2010 =C3=A0 13:17 +0000, Fischer, Anna a =C3=A9crit :
> Hi,
>=20
> Does the Linux kernel network stack do any specific handling of=20

> link-local address configuration and handling according to RFC 3927?

>  I know that there is user-level code like Zeroconf / Avahi and these

>  tools create ARP sockets directly on the specified network interface=
s=20

> in order to support link-local address handling. But if I do not=20

> run any of these tools, does the kernel's ARP code take care of this,=
 too?
>=20

There is no RFC 3927 support in kernel, you need user space support (or
switch to DHCP ;) )

Note that ARP replies MUST also be broadcasted for this particular
169.254/16 network (RFC 3927, 2.5), you need a kernel patch too, this
was discussed 4 years ago on netdev, and nothing was decided/changed.

http://marc.info/?l=3Dlinux-netdev&m=3D114427223811197&w=3D2


BTW I believe that our forwarding path doesnt test source/destination
address not being part of 169.254/16 network, I am not sure it
is a real problem or not. A netfilter rule can fix it eventually.

7.  Router Considerations

   A router MUST NOT forward a packet with an IPv4 Link-Local source or
   destination address, irrespective of the router's default route
   configuration or routes obtained from dynamic routing protocols.

   A router which receives a packet with an IPv4 Link-Local source or
   destination address MUST NOT forward the packet.  This prevents
   forwarding of packets back onto the network segment from which they
   originated, or to any other segment.






