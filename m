From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: ECMP ipv6 vs ipv4
Date: Mon, 15 Apr 2013 17:51:46 +0200
Message-ID: <516C2212.4030502@6wind.com>
References: <1366012728.4975.13.camel@localhost>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Wilco Baan Hofman <wilco@baanhofman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35037 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403Ab3DOPvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 11:51:50 -0400
Received: by mail-wi0-f176.google.com with SMTP id hm14so1714048wib.3
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 08:51:49 -0700 (PDT)
In-Reply-To: <1366012728.4975.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2013 09:58, Wilco Baan Hofman a =C3=A9crit :
> Hi,
>
> I'm working on a patch to implement 'nexthop weight' for multipath ip=
v6.
> However, the ECMPv6 implementation has a few flaws that are quite
> annoying.
>
> One of the flaws is that the netlink nexthop API is asymmetrical, you
> can add nexthops through the netlink API, but when the result is
> requested it is completely different, resulting in bird6 removing the
> route as it does not match the initial route set.
In fact, there is two ways to add ECMP routes:
$ ip -6 route add 3ffe:304:124:2306::/64 \
	nexthop via fe80::230:1bff:feb4:e05c dev eth0 \
	nexthop via fe80::230:1bff:feb4:dd4f dev eth0
or
$ ip -6 route add 3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:dd4f d=
ev
eth0
$ ip -6 route append 3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:e05=
c dev
eth0

Note that the second way matchs what is returned by the kernel (ie one =
entry per=20
nexthop).

>
> Another one of the flaws is that if I add nexthop weight or algorithm
> (weighted hash or weighted random) I need to add this to the main rt
> node, this seems like an inefficient memory structure, as this needs =
to
> be added to all the siblings as well.
Nexthop weight (rtnh->rtnh_hops) is not implemented.

>
> I propose that we have a nexthop structure to an exclusive route,
> similar what we have for IPv4, where we store the gateway, device and
> weight for all nexthops and the algorithm in the route. This would ma=
ke
> the netlink API symmetrical again and fixes the n*n inefficiencies wh=
en
> adding routes (all siblings need to know about all siblings).
>
> What are your thoughts on this?
>
> Regards,
>
> Wilco Baan Hofman
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
