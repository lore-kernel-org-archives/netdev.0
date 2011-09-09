From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Fri, 09 Sep 2011 07:30:23 +0200
Message-ID: <1315546223.5410.23.camel@edumazet-laptop>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kumar S <ps2kumar@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38983 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542Ab1IIFaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 01:30:30 -0400
Received: by wwf5 with SMTP id 5so723380wwf.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 22:30:29 -0700 (PDT)
In-Reply-To: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 septembre 2011 =C3=A0 22:04 -0700, Kumar S a =C3=A9crit :
> Hi,
> We are running Linux-2.6.24 kernel on MPC8360. Though forwarding is
> disabled, when connected to public network we see the system running
> out of memory and rebooting frequently. After doing some study we
> found out slowly "ip_dst-cache" is growing, and doesn't release
> entries. Interestingly route entries displayed with command "ip route
> ls cache" show fewer than the active objects listed under
> "cat /proc/slabinfo | grep ip_dst_cache". After doing some study, we
> could reproduce it in the lab by injecting packets withdifferent
> source IP addresses. Ideally ageing should happen, and old entries ar=
e
> supposed to be cleared out, but that doesn't happen. We do see one or
> two entries getting agedout but not all.=20
> After some time we did see that "rt_run_flush" kicks in and flushes
> out the ip_dst_cache. That's why the "ip route ls cache" fewer
> entries. But looks like __chache_free() doesn't get called, that's wh=
y
> these entries are not really released. This results in the leak.
> =20
> Any idea what is going wrong here. Is it a known bug?

Please send :

grep . /proc/sys/net/ipv4/route/*
rtstat -c10 -i1

This a very well known problem. You need to upgrade your kernel in orde=
r
to avoid very complex tuning of your IP route cache.

Recent ones have smooth garbage collection.

In the meantime, you can tune a bit :

echo 1 >/proc/sys/net/ipv4/route/gc_interval
echo 4 >/proc/sys/net/ipv4/route/gc_elasticity
