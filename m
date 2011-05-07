From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 18:26:29 +0200
Message-ID: <1304785589.3207.5.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52712 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755783Ab1EGQ0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 12:26:33 -0400
Received: by wya21 with SMTP id 21so3030287wya.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 09:26:32 -0700 (PDT)
In-Reply-To: <0F4A638C2A523577CDBC295E@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 16:26 +0100, Alex Bligh a =C3=A9crit :

> On the current 8 core box I am testing, I see 280ms per interface
> delete **even with only 10 interfaces**. I see 260ms with one
> interface. I know doing lots of rcu sync stuff can be slow, but
> 260ms to remove one veth pair sounds like more than rcu sync going
> on. It sounds like a sleep (though I may not have found the
> right one). I see no CPU load.
>=20

Here, on 2.6.38 kernel (Ubuntu 11.04 provided, on my 2 core laptop)

# time rmmod dummy

real	0m0.111s
user	0m0.000s
sys	0m0.000s


This removed my two dummy0/dummy1 devices.

On another machine with a very recent kernel :
$ modprobe dummy numdummies=3D1
$ ifconfig dummy0 192.168.46.46 up
$ time rmmod dummy

real	0m0.032s
user	0m0.000s
sys	0m0.001s
$ uname -a
Linux svivoipvnx001 2.6.39-rc6-00097-g6ac1576-dirty #550 SMP Sat May 7
00:12:26 CEST 2011 i686 i686 i386 GNU/Linux


So 260ms is a bit too much, maybe you hit yet another bug.




