From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Tue, 10 Jun 2014 22:54:50 -0700
Message-ID: <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	  <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.DEB.2.02.1406101726390.11647@dtop>
	  <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.10.1406102114520.28698@dinf>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:63037 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbaFKFyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 01:54:51 -0400
Received: by mail-pb0-f47.google.com with SMTP id un15so1652625pbc.6
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 22:54:51 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.10.1406102114520.28698@dinf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-10 at 21:16 -0700, dormando wrote:

> Ran our udpkill util against 3.10.42 with both of your patches applied...
> seems like it ran a bit longer than normally would with this test (15-20
> minutes), then died:

Well, could you try a recent kernel instead ?

I can see some races and fixes are probably worth it.

$ git log --oneline v3.10.42..v3.15 net/ipv4/route.c
fbdc0ad ipv4: initialise the itag variable in __mkroute_input
0d5edc6 ipv4, route: pass 0 instead of LOOPBACK_IFINDEX to fib_validate_source()
aad8872 ipv4: add a sock pointer to dst->output() path.
9114615 ipv4: return valid RTA_IIF on ip route get
3ed66e9 net: replace __this_cpu_inc in route.c with raw_cpu_inc
0b8c7f6 ipv4: remove ip_rt_dump from route.c
4a4eb21 ipv4: remove ipv4_ifdown_dst from route.c
1e8d642 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
a625486 ipv4: fix counter in_slow_tot
cd0f0b9 ipv4: distinguish EHOSTUNREACH from the ENETUNREACH
2045cea net: remove unnecessary return's
f87c10a ipv4: introduce ip_dst_mtu_maybe_forward and protect forwarding path against pmtu spoofing
dcdfdf5 ipv4: fix race in concurrent ip_route_input_slow()
482fc60 ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
0baf2b3 ipv4: shrink rt_cache_stat
0a7e226 ipv4: fix ineffective source address selection
734d272 ipv4: raise IP_MAX_MTU to theoretical limit
ca4c3fc net: split rt_genid for ipv4 and ipv6
2ffae99 ipv4: use next hop exceptions also for input routes
fe2c633 net: Convert uses of typedef ctl_table to struct ctl_table
6bc19fb Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
5aad1de ipv4: use separate genid for next hop exceptions
f016229 ipv4: rate limit updating of next hop exceptions with same pmtu
387aa65 ipv4: properly refresh rtable entries on pmtu/redirect events
