From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux Route Cache performance tests
Date: Sun, 06 Nov 2011 20:38:10 +0100
Message-ID: <1320608290.6506.33.camel@edumazet-laptop>
References: <4EB6AE62.5050803@itcare.pl>
	  <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>
	 <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62823 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab1KFTiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2011 14:38:15 -0500
Received: by wyh15 with SMTP id 15so3843069wyh.19
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2011 11:38:13 -0800 (PST)
In-Reply-To: <4EB6DE06.7050009@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 06 novembre 2011 =C3=A0 20:20 +0100, Pawe=C5=82 Staszewski =
a =C3=A9crit :
> W dniu 2011-11-06 19:48, Eric Dumazet pisze:
> > Le dimanche 06 novembre 2011 =C3=A0 19:28 +0100, Pawe=C5=82 Staszew=
ski a =C3=A9crit :
> >> W dniu 2011-11-06 18:29, Eric Dumazet pisze:
> >>> Le dimanche 06 novembre 2011 =C3=A0 16:57 +0100, Pawe=C5=82 Stasz=
ewski a =C3=A9crit :
> >>>> Hello
> >>>>
> >>>>
> >>>>
> >>>> I make some networking performance tests for Linux 3.1
> >>>>
> >>>> Configuration:
> >>>>
> >>>> Linux (pktget) ---->   Linux (router) ---->   Linux (Sink)
> >>>>
> >>>> pktgen config:
> >>>> clone_skb 32
> >>>> pkt_size 64
> >>>> delay 0
> >>>>
> >>>> pgset "flag IPDST_RND"
> >>>> pgset "dst_min 10.0.0.0"
> >>>> pgset "dst_max 10.18.255.255"
> >>>> pgset "config 1"
> >>>> pgset "flows 256"
> >>>> pgset "flowlen 8"
> >>>>
> >>>> TX performance for this host:
> >>>> eth0:            RX: 0.00 P/s      TX: 12346107.73 P/s      TOTA=
L:
> >>>> 12346107.73 P/s
> >>>>
> >>>> On Linux (router):
> >>>> grep . /proc/sys/net/ipv4/route/*
> >>>> /proc/sys/net/ipv4/route/error_burst:500
> >>>> /proc/sys/net/ipv4/route/error_cost:100
> >>>> grep: /proc/sys/net/ipv4/route/flush: Permission denied
> >>>> /proc/sys/net/ipv4/route/gc_elasticity:4
> >>>> /proc/sys/net/ipv4/route/gc_interval:60
> >>>> /proc/sys/net/ipv4/route/gc_min_interval:0
> >>>> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
> >>>> /proc/sys/net/ipv4/route/gc_thresh:2000000
> >>>> /proc/sys/net/ipv4/route/gc_timeout:60
> >>>> /proc/sys/net/ipv4/route/max_size:8388608
> >>>> /proc/sys/net/ipv4/route/min_adv_mss:256
> >>>> /proc/sys/net/ipv4/route/min_pmtu:552
> >>>> /proc/sys/net/ipv4/route/mtu_expires:600
> >>>> /proc/sys/net/ipv4/route/redirect_load:2
> >>>> /proc/sys/net/ipv4/route/redirect_number:9
> >>>> /proc/sys/net/ipv4/route/redirect_silence:2048
> >>>>
> >>>> For the first 30secs maybee more router is forwarding ~5Mpps to =
the
> >>>> Linux (Sink)
> >>>> and some stats for this forst 30secs in attached image:
> >>>>
> >>>> http://imageshack.us/photo/my-images/684/test1ih.png/
> >>>>
> >>>> Left up - pktgen linux
> >>>> left down - Linux router (htop)
> >>>> Right up - Linux router (bwm-ng - showing pps)
> >>>> Right down - Linux router (lnstat)
> >>>>
> >>>>
> >>>> And all is good - performance 5Mpps until Linux router will reac=
h ~1kk
> >>>> entries
> >>>> What You can see on next attached image:
> >>>>
> >>>> http://imageshack.us/photo/my-images/24/test2id.png/
> >>>>
> >>>> Forwarding performance drops from 5Mpps to 1,8Mpps
> >>>> And after 3 - 4 minutes it will stop on 0,7Mpps
> >>>>
> >>>>
> >>>> After flushing the route cache performance increase from 0.7Mpps=
 to 6Mpps
> >>>> What You can see on next attached image:
> >>>>
> >>>> http://imageshack.us/photo/my-images/197/test3r.png/
> >>>>
> >>>> Is it possible to turn off route cache ? and see what performanc=
e will
> >>>> be without caching
> >>>>
> >>> Route cache cannot handle DDOS situation, since it will be filled=
,
> >>> unless you have a lot of memory.
> >> hmm
> >> but what is DDOS situation for route cache ? new entries per sec ?=
 total
> >> amount of entries 1,2kk in my tests ?
> >> Look sometimes in normal scenario You can hit
> >> 1245072 route cache entries
> >> This is normal for BGP configurations.
> >>
> > Then figure out the right tunables for your machine ?
> >
> > Its not a laptop or average server setup, so you need to allow your
> > kernel to consume a fair amount of memory for the route cache.
> Yes this parameters  was special not tuned :)
> To see what is the route cache performance limit
>=20

Hmm, I thought you were asking for help on netdev ?

> Because there was no optimal parameters for this test :)
> no matter what i tuned results are always the same
> performance drops from 5Mpps to 0.7Mpps without tuning sysctl
>=20
> And with tuned parameters i can reach the same as turning off route=20
> cache - when running this tests.
> So Yes Tuned performance is better
> performance drops from 5Mpps to 0.7Mpps - without tuning
> and from 5Mpps to 3,7Mpps with tuned sysctl - so a little less than w=
ith=20
> turned off route cache
>=20
> So the point of this test was figure out how much of route cache entr=
ies=20
> Linux can handle without dropping performance.

No need to even do a bench, its pretty easy to understand how a hash
table is handled.

Allowing long chains is not good.

With your 512k slots hash table, you cannot expect handling 1.4M routes
with optimal performance. End of story.

Since route hash table is allocated at boot time, only way to change it=
s
size is using "rhash_entries=3D2097152" boot parameter.

If it still doesnt fly, try with "rhash_entries=3D4194304"
