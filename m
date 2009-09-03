From: "Holger Hoffstaette" <holger.hoffstaette@googlemail.com>
Subject: Re: Network hangs with 2.6.30.5
Date: Thu, 03 Sep 2009 21:55:39 +0200
Message-ID: <pan.2009.09.03.19.55.37.672875@googlemail.com>
References: <pan.2009.09.01.15.32.24.613750@googlemail.com> <20090903074610.GA6000@ff.dom.local> <pan.2009.09.03.19.20.44.736875@googlemail.com> <4AA0188C.20107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:34444 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756135AbZICT4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 15:56:06 -0400
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1MjIPf-0004OC-87
	for netdev@vger.kernel.org; Thu, 03 Sep 2009 21:56:07 +0200
Received: from port-87-234-135-12.dynamic.qsc.de ([87.234.135.12])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2009 21:56:07 +0200
Received: from holger.hoffstaette by port-87-234-135-12.dynamic.qsc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2009 21:56:07 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Sep 2009 21:27:08 +0200, Eric Dumazet wrote:

> Holger Hoffstaette a =E9crit :
>> Problem found! At least for me..
>>=20
>>> On 01-09-2009 17:32, Holger Hoffstaette wrote:
>>>> On Tue, 01 Sep 2009 16:17:08 +0200, Holger Hoffstaette wrote:
>>>>
>>>> [network regressions in .30]
>>=20
>> I got the git .30.y stable tree and reverted various e1000 commits t=
hat
>> seemed to coincide with the various .30-rc releases but nothing help=
ed.
>> Also no relation to offloads etc.
>>=20
>> However I did notice that the "stuck squid" problem seemed to magica=
lly
>> fix itself after a few seconds - then hang again, fix itself after
>> timeouts etc. So I suspected something TCP related and BINGO!
>>=20
>> Turns out I had both tcp_tw_recycle and tcp_tw_reuse set to 1 for
>> reasons I don't want to explain. :)
>>=20
>> I can now arbitrarily fix the hanging behaviour by setting
>> tcp_tw_recycle to 0, and cause hangs by setting it to 1 again. For
>> obvious reasons this seems to affect squid more than other tasks wit=
h
>> more long-lived connections. What is the right behaviour? beats me.
>>=20
>> tcp_tw_reuse does not appear to play a role, so the real culprit at
>> least in my case seems to be tcp_tw_recycle. In previous releases th=
is
>> (and tw_reuse) was necessary for various server tasks.
>>=20
>> Nevertheless, something has changed between .29 and .30 that "broke"=
 the
>> previous behaviour. Whether this is progress or an regression I cann=
ot
>> say. Maybe someone else has an idea?
>>=20
>>=20
> Well... not yet :)
>=20
> We probably can reproduce this problem with any NIC...
>=20
> Could you send from the 'buggy' setup
>=20
> $ grep . /proc/sys/net/ipv4/*

Sure:

root>grep . /proc/sys/net/ipv4/*
grep: /proc/sys/net/ipv4/conf: Invalid argument
/proc/sys/net/ipv4/icmp_echo_ignore_all:0
/proc/sys/net/ipv4/icmp_echo_ignore_broadcasts:1
/proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr:0
/proc/sys/net/ipv4/icmp_ignore_bogus_error_responses:1
/proc/sys/net/ipv4/icmp_ratelimit:1000
/proc/sys/net/ipv4/icmp_ratemask:6168
/proc/sys/net/ipv4/igmp_max_memberships:20
/proc/sys/net/ipv4/igmp_max_msf:10
/proc/sys/net/ipv4/inet_peer_gc_maxtime:120
/proc/sys/net/ipv4/inet_peer_gc_mintime:10
/proc/sys/net/ipv4/inet_peer_maxttl:600
/proc/sys/net/ipv4/inet_peer_minttl:120
/proc/sys/net/ipv4/inet_peer_threshold:65664
/proc/sys/net/ipv4/ip_default_ttl:64
/proc/sys/net/ipv4/ip_dynaddr:0
/proc/sys/net/ipv4/ip_forward:0
/proc/sys/net/ipv4/ip_local_port_range:32768    61000
/proc/sys/net/ipv4/ip_no_pmtu_disc:0
/proc/sys/net/ipv4/ip_nonlocal_bind:0
/proc/sys/net/ipv4/ipfrag_high_thresh:8388608
/proc/sys/net/ipv4/ipfrag_low_thresh:1048575
/proc/sys/net/ipv4/ipfrag_max_dist:64
/proc/sys/net/ipv4/ipfrag_secret_interval:600
/proc/sys/net/ipv4/ipfrag_time:30
grep: /proc/sys/net/ipv4/neigh: Invalid argument
grep: /proc/sys/net/ipv4/route: Invalid argument
/proc/sys/net/ipv4/rt_cache_rebuild_count:4
/proc/sys/net/ipv4/tcp_abc:0
/proc/sys/net/ipv4/tcp_abort_on_overflow:0
/proc/sys/net/ipv4/tcp_adv_win_scale:2
/proc/sys/net/ipv4/tcp_allowed_congestion_control:cubic reno
/proc/sys/net/ipv4/tcp_app_win:31
/proc/sys/net/ipv4/tcp_available_congestion_control:cubic reno
/proc/sys/net/ipv4/tcp_base_mss:512
/proc/sys/net/ipv4/tcp_congestion_control:cubic
/proc/sys/net/ipv4/tcp_dsack:1
/proc/sys/net/ipv4/tcp_ecn:0
/proc/sys/net/ipv4/tcp_fack:1
/proc/sys/net/ipv4/tcp_fin_timeout:60
/proc/sys/net/ipv4/tcp_frto:2
/proc/sys/net/ipv4/tcp_frto_response:0
/proc/sys/net/ipv4/tcp_keepalive_intvl:75
/proc/sys/net/ipv4/tcp_keepalive_probes:9
/proc/sys/net/ipv4/tcp_keepalive_time:7200
/proc/sys/net/ipv4/tcp_low_latency:0
/proc/sys/net/ipv4/tcp_max_orphans:16384
/proc/sys/net/ipv4/tcp_max_ssthresh:0
/proc/sys/net/ipv4/tcp_max_syn_backlog:1024
/proc/sys/net/ipv4/tcp_max_tw_buckets:180000
/proc/sys/net/ipv4/tcp_mem:82944        110592  165888
/proc/sys/net/ipv4/tcp_moderate_rcvbuf:1
/proc/sys/net/ipv4/tcp_mtu_probing:0
/proc/sys/net/ipv4/tcp_no_metrics_save:0
/proc/sys/net/ipv4/tcp_orphan_retries:0
/proc/sys/net/ipv4/tcp_reordering:3
/proc/sys/net/ipv4/tcp_retrans_collapse:1
/proc/sys/net/ipv4/tcp_retries1:3
/proc/sys/net/ipv4/tcp_retries2:15
/proc/sys/net/ipv4/tcp_rfc1337:0
/proc/sys/net/ipv4/tcp_rmem:4096        262144  8388608
/proc/sys/net/ipv4/tcp_sack:1
/proc/sys/net/ipv4/tcp_slow_start_after_idle:1
/proc/sys/net/ipv4/tcp_stdurg:0
/proc/sys/net/ipv4/tcp_syn_retries:5
/proc/sys/net/ipv4/tcp_synack_retries:5
/proc/sys/net/ipv4/tcp_timestamps:1
/proc/sys/net/ipv4/tcp_tso_win_divisor:3
/proc/sys/net/ipv4/tcp_tw_recycle:1
/proc/sys/net/ipv4/tcp_tw_reuse:1
/proc/sys/net/ipv4/tcp_window_scaling:1
/proc/sys/net/ipv4/tcp_wmem:4096        262144  8388608
/proc/sys/net/ipv4/tcp_workaround_signed_windows:0
/proc/sys/net/ipv4/udp_mem:82944        110592  165888
/proc/sys/net/ipv4/udp_rmem_min:4096
/proc/sys/net/ipv4/udp_wmem_min:4096
root>=20

> When you say squid is stuck, does it mean it doesnt accept new connec=
tions
> ?

Yes, that seems to be the behaviour. To verify - I just browse any rand=
om
website and after a few requests the browser does not get any replies a=
ny
longer, timeouts etc. After setting tw_recycle to 0 it immediately star=
ts
working again (and then continues to work).

Took a bit to find out in which direction things were hanging/getting
stuck, since it was not immediately clear from simply observing the cli=
ent.

> Could help to strace it and check what it is doing ? --

After a quite frantic start (endless amount of 54 byte writes??) it sit=
s
in its epoll loop and waits:

=2E.
epoll_wait(4, {}, 8192, 1000)           =3D 0
gettimeofday({1252007105, 637264}, NULL) =3D 0
gettimeofday({1252007105, 637309}, NULL) =3D 0
epoll_wait(4, {}, 8192, 1000)           =3D 0
gettimeofday({1252007106, 637262}, NULL) =3D 0
gettimeofday({1252007106, 637308}, NULL) =3D 0
epoll_wait(4, {}, 8192, 0)              =3D 0
gettimeofday({1252007106, 637389}, NULL) =3D 0
gettimeofday({1252007106, 637421}, NULL) =3D 0
epoll_wait(4, {}, 8192, 1000)           =3D 0
gettimeofday({1252007107, 637266}, NULL) =3D 0
gettimeofday({1252007107, 637311}, NULL) =3D 0
=2E.etc..

and occasionally diddles with its cache directory:

=2E.
epoll_wait(4, {}, 8192, 997)            =3D 0
gettimeofday({1252007148, 554039}, NULL) =3D 0
gettimeofday({1252007148, 554097}, NULL) =3D 0
open("/var/cache/squid/02/09", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECT=
ORY|O_CLOEXEC) =3D 9
getdents64(9, /* 113 entries */, 32768) =3D 3600
getdents64(9, /* 0 entries */, 32768)   =3D 0
close(9)                                =3D 0
epoll_wait(4, {}, 8192, 0)              =3D 0
gettimeofday({1252007148, 555923}, NULL) =3D 0
=2E.

When requests come in, it does whatever squid does, but when it hangs, =
the
following popped up:

gettimeofday({1252007207, 116223}, NULL) =3D 0
epoll_ctl(4, EPOLL_CTL_MOD, 23, {EPOLLIN|EPOLLERR|EPOLLHUP, {u32=3D23, =
u64=3D582647025628086295}}) =3D 0
gettimeofday({1252007207, 116380}, NULL) =3D 0
epoll_wait(4, {{EPOLLIN, {u32=3D15, u64=3D582647025628086287}}}, 8192, =
359) =3D 1
gettimeofday({1252007207, 117309}, NULL) =3D 0
read(15, "48,33,48,31,40,31\" href=3D\"/2/hi/af"..., 2046) =3D 581
gettimeofday({1252007207, 117476}, NULL) =3D 0
epoll_ctl(4, EPOLL_CTL_MOD, 23, {EPOLLIN|EPOLLOUT|EPOLLERR|EPOLLHUP, {u=
32=3D23, u64=3D23}}) =3D 0
epoll_wait(4, {{EPOLLIN, {u32=3D15, u64=3D582647025628086287}}, {EPOLLO=
UT, {u32=3D23, u64=3D23}}}, 8192, 358) =3D 2
gettimeofday({1252007207, 117790}, NULL) =3D 0
read(15, ""..., 2046)                   =3D 0
write(23, "48,33,48,31,40,31\" href=3D\"/2/hi/af"..., 581) =3D 581
gettimeofday({1252007207, 118032}, NULL) =3D 0
read(15, ""..., 65535)                  =3D 0
read(23, 0xbf925401, 65535)             =3D -1 EAGAIN (Resource tempora=
rily unavailable)
epoll_ctl(4, EPOLL_CTL_DEL, 15, {0, {u32=3D15, u64=3D15}}) =3D 0
close(15)                               =3D 0
epoll_ctl(4, EPOLL_CTL_MOD, 23, {EPOLLOUT|EPOLLERR|EPOLLHUP, {u32=3D23,=
 u64=3D581683939341500439}}) =3D 0
epoll_ctl(4, EPOLL_CTL_DEL, 23, {0, {u32=3D23, u64=3D581683939341500439=
}}) =3D 0
close(23)                               =3D 0
epoll_wait(4, {}, 8192, 357)            =3D 0
gettimeofday({1252007207, 477363}, NULL) =3D 0
gettimeofday({1252007207, 477408}, NULL) =3D 0
epoll_wait(4, {}, 8192, 0)              =3D 0
gettimeofday({1252007207, 477561}, NULL) =3D 0
gettimeofday({1252007207, 477629}, NULL) =3D 0
epoll_wait(4, {}, 8192, 449)            =3D 0

Then it again spins in the epoll loop for a while until it recovers and
starts to handle the outstanding requests (as far as I can read - it
scrolls by too quickly).

Was that somewhat helpful? I can certainly create a full trace but that=
's
going to be big.

regards
Holger


