From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more
 per-cpu memory?
Date: Mon, 08 Nov 2010 22:40:28 +0100
Message-ID: <1289252428.2790.18.camel@edumazet-laptop>
References: <4CD43C87.5040403@candelatech.com>
	 <1288980361.2882.1070.camel@edumazet-laptop>
	 <4CD449A5.5070305@candelatech.com>
	 <1288988403.2665.268.camel@edumazet-laptop>
	 <1288995103.2665.653.camel@edumazet-laptop>
	 <4CD49C2F.3060904@candelatech.com>
	 <1289028392.2665.2418.camel@edumazet-laptop>
	 <4CD58B9C.2030006@candelatech.com>
	 <1289214131.2820.187.camel@edumazet-laptop>
	 <4CD86B4D.6020406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42673 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab0KHVke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:40:34 -0500
Received: by wwb18 with SMTP id 18so411493wwb.1
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 13:40:33 -0800 (PST)
In-Reply-To: <4CD86B4D.6020406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 novembre 2010 =C3=A0 13:27 -0800, Ben Greear a =C3=A9crit :
> On 11/08/2010 03:02 AM, Eric Dumazet wrote:
> > Le samedi 06 novembre 2010 =C3=A0 10:08 -0700, Ben Greear a =C3=A9c=
rit :
> >
> >> At least I don't see any percpu dumps in dmesg.  I vaguely remembe=
r
> >> someone posting some ipv6 address scalability patches some time ba=
ck.
> >> I think they had to hack on /proc fs as well.  I'll see if I can
> >> dig those up.
> >>
> >>> Make sure udev / hotplug is not the problem, if you create your d=
evices
> >>> very fast.
> >>
> >> We can create the macvlans w/out problem, though I'm sure that cou=
ld
> >> be sped up.  The problem is when we try to add IPv6 addresses to
> >> them.
> >
> > I see. Did you check /proc/sys/net/ipv6/ tunables ?
> >
> > For example, I bet you need to make route/max_size a bigger value t=
han
> > default (4096)
>=20
> I'm having a hard time figuring out how this actually causes somethin=
g
> to fail.
>=20
> It seems that having max_size too small would cause the garbage colle=
ctor
> logic to happen more often, but I don't see any place it actually
> removes or limits entries, and I can't find any other references to
> ip6_rt_max_size.
>=20
> I must just be missing something..so if you have any ideas where to
> look, I'd love to hear it!
>=20

ipv6_add_addr() calls addrconf_dst_alloc
addrconf_dst_alloc() calls dst_alloc
dst_alloc() calls ip6_dst_gc
ip6_dst_gc() calls fib6_run_gc
fib6_run_gc() calls icmp6_dst_gc
fib6_run_gc() calls fib6_clean_all

a bit later, we return to ipv6_add_addr() (line 644) with an error

You want to add a warning in net/ipv6/route.c, line 1949

Thanks




