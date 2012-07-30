From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [net-next,v3] GRE over IPv6
Date: Mon, 30 Jul 2012 14:38:06 +0300
Message-ID: <20120730143806.41f759fd@vostro>
References: <1368610.TAsHNfv2Eb@comp1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51604 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab2G3Liv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 07:38:51 -0400
Received: by eaak13 with SMTP id k13so1080897eaa.19
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2012 04:38:50 -0700 (PDT)
In-Reply-To: <1368610.TAsHNfv2Eb@comp1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Jul 2012 22:12:42 -0000 xeb@mail.ru wrote:

> GRE over IPv6 implementation.
> 
> Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
> 
> ---
> Changes:
> Initialize nt->dev before calling ip6gre_tnl_link_config in
> ip6gre_newlink.
> Add missing ip6gre.c
> 
>  include/linux/if_arp.h     |    1 +
>  include/linux/if_tunnel.h  |    3 +
>  include/linux/ip6_tunnel.h |   18 +
>  include/net/ip6_tunnel.h   |   40 +-
>  include/net/ipv6.h         |    1 +
>  net/ipv6/Kconfig           |   16 +
>  net/ipv6/Makefile          |    1 +
>  net/ipv6/ip6_gre.c         | 1817
> ++++++++++++++++++++++++++++++++++++++++++++
> net/ipv6/ip6_tunnel.c      |   86 ++- 9 files changed, 1958
> insertions(+), 25 deletions(-)

Would it be possible and/or feasible to instead modify ip_gre to support
also ipv6 as outer protocol? 

It already has ipv6 stuff in it for the inner protocol support. And it
would avoid duplicating most of the code.

And I would especially love that approach, since I could then on
per-target basis say if it should be contacted with IPv4 or IPv6. As in:
 
  ip addr add 10.0.0.1/24 dev gre1
  ip neigh add 10.0.0.2 lladdr 192.168.x.x dev gre1 nud permanent
  ip neigh add 10.0.0.3 lladdr fe80::xxxx:xxxx:xxxx:xxxx/64 dev gre1 nud permanent

- Timo
