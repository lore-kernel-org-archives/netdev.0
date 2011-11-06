From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux Route Cache performance tests
Date: Sun, 06 Nov 2011 18:29:57 +0100
Message-ID: <1320600597.6506.7.camel@edumazet-laptop>
References: <4EB6AE62.5050803@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56398 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab1KFRaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2011 12:30:02 -0500
Received: by wwi36 with SMTP id 36so5688675wwi.1
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2011 09:30:01 -0800 (PST)
In-Reply-To: <4EB6AE62.5050803@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 06 novembre 2011 =C3=A0 16:57 +0100, Pawe=C5=82 Staszewski =
a =C3=A9crit :
> Hello
>=20
>=20
>=20
> I make some networking performance tests for Linux 3.1
>=20
> Configuration:
>=20
> Linux (pktget) ----> Linux (router) ----> Linux (Sink)
>=20
> pktgen config:
> clone_skb 32
> pkt_size 64
> delay 0
>=20
> pgset "flag IPDST_RND"
> pgset "dst_min 10.0.0.0"
> pgset "dst_max 10.18.255.255"
> pgset "config 1"
> pgset "flows 256"
> pgset "flowlen 8"
>=20
> TX performance for this host:
> eth0:            RX: 0.00 P/s      TX: 12346107.73 P/s      TOTAL:=20
> 12346107.73 P/s
>=20
> On Linux (router):
> grep . /proc/sys/net/ipv4/route/*
> /proc/sys/net/ipv4/route/error_burst:500
> /proc/sys/net/ipv4/route/error_cost:100
> grep: /proc/sys/net/ipv4/route/flush: Permission denied
> /proc/sys/net/ipv4/route/gc_elasticity:4
> /proc/sys/net/ipv4/route/gc_interval:60
> /proc/sys/net/ipv4/route/gc_min_interval:0
> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
> /proc/sys/net/ipv4/route/gc_thresh:2000000
> /proc/sys/net/ipv4/route/gc_timeout:60
> /proc/sys/net/ipv4/route/max_size:8388608
> /proc/sys/net/ipv4/route/min_adv_mss:256
> /proc/sys/net/ipv4/route/min_pmtu:552
> /proc/sys/net/ipv4/route/mtu_expires:600
> /proc/sys/net/ipv4/route/redirect_load:2
> /proc/sys/net/ipv4/route/redirect_number:9
> /proc/sys/net/ipv4/route/redirect_silence:2048
>=20
> For the first 30secs maybee more router is forwarding ~5Mpps to the=20
> Linux (Sink)
> and some stats for this forst 30secs in attached image:
>=20
> http://imageshack.us/photo/my-images/684/test1ih.png/
>=20
> Left up - pktgen linux
> left down - Linux router (htop)
> Right up - Linux router (bwm-ng - showing pps)
> Right down - Linux router (lnstat)
>=20
>=20
> And all is good - performance 5Mpps until Linux router will reach ~1k=
k=20
> entries
> What You can see on next attached image:
>=20
> http://imageshack.us/photo/my-images/24/test2id.png/
>=20
> Forwarding performance drops from 5Mpps to 1,8Mpps
> And after 3 - 4 minutes it will stop on 0,7Mpps
>=20
>=20
> After flushing the route cache performance increase from 0.7Mpps to 6=
Mpps
> What You can see on next attached image:
>=20
> http://imageshack.us/photo/my-images/197/test3r.png/
>=20
> Is it possible to turn off route cache ? and see what performance wil=
l=20
> be without caching
>=20

Route cache cannot handle DDOS situation, since it will be filled,
unless you have a lot of memory.

I am not sure what you expected here. If caches misses are too frequent=
,
a cache is useless, whatever how its done.

If you disable route cache, you'll get poor performance in normal
situation (99.9999% of cases, non DDOS), and same performance on DDOS,
in 0.0001% cases

Trick to disable it is to use a big (and negative) rebuild_count

$ echo 3000000000 >/proc/sys/net/ipv4/rt_cache_rebuild_count
$ cat /proc/sys/net/ipv4/rt_cache_rebuild_count
-1294967296
