From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem wit route cache
Date: Mon, 08 Feb 2010 14:51:07 +0100
Message-ID: <1265637067.3048.14.camel@edumazet-laptop>
References: <4B700EC2.5090207@itcare.pl>
	 <1265635690.3048.8.camel@edumazet-laptop>  <4B7012BC.9000702@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:50615 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212Ab0BHNvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 08:51:10 -0500
Received: by bwz23 with SMTP id 23so1108702bwz.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 05:51:09 -0800 (PST)
In-Reply-To: <4B7012BC.9000702@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 f=C3=A9vrier 2010 =C3=A0 14:33 +0100, Pawe=C5=82 Staszewski=
 a =C3=A9crit :

> >   =20
> Yes this is x86_64 kernel
> i kernels  2.6.32.2 /  2.6.32.7 and now 2.6.33-rc6-git5 and on all=20
> kernels the same thing happens.
> grep . /proc/sys/net/ipv4/route/*
> /proc/sys/net/ipv4/route/error_burst:1250
> /proc/sys/net/ipv4/route/error_cost:250
> grep: /proc/sys/net/ipv4/route/flush: Permission denied
> /proc/sys/net/ipv4/route/gc_elasticity:2
> /proc/sys/net/ipv4/route/gc_interval:2
> /proc/sys/net/ipv4/route/gc_min_interval:0
> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
> /proc/sys/net/ipv4/route/gc_thresh:65535
> /proc/sys/net/ipv4/route/gc_timeout:300
> /proc/sys/net/ipv4/route/max_size:524288
> /proc/sys/net/ipv4/route/min_adv_mss:256
> /proc/sys/net/ipv4/route/min_pmtu:552
> /proc/sys/net/ipv4/route/mtu_expires:600
> /proc/sys/net/ipv4/route/redirect_load:5
> /proc/sys/net/ipv4/route/redirect_number:9
> /proc/sys/net/ipv4/route/redirect_silence:5120
> /proc/sys/net/ipv4/route/secret_interval:2
>=20
> This happens not all the time.
> I have this info only when there are "internet rush hours" - thn ther=
e=20
> is about 700Mbit/s TX + 700Mbit/s RX forwarded traffic
>=20

I dont understand your settings, they are very very small for your
setup. You want to flush cache every 2 seconds...

With 12GB of ram, you could have=20

/proc/sys/net/ipv4/route/gc_thresh:524288
/proc/sys/net/ipv4/route/max_size:8388608
/proc/sys/net/ipv4/route/secret_interval:3600
/proc/sys/net/ipv4/route/gc_elasticity:4
/proc/sys/net/ipv4/route/gc_interval:1

That would allow about 2 million entries in your route cache, using 768
Mbytes of ram, and a good cache hit ratio.





