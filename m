From: Duan Jiong <djduanjiong@gmail.com>
Subject: Re: [PATCH  v3 0/6] ipv6: Do route updating for redirect in ndisc
 layer
Date: Mon, 16 Sep 2013 20:41:03 +0800
Message-ID: <5236FC5F.9090804@gmail.com>
References: <5236EFEB.60106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:50456 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009Ab3IPMlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 08:41:13 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so4054946pdj.22
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 05:41:13 -0700 (PDT)
In-Reply-To: <5236EFEB.60106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

davem,

please just ignore this patch set this time, i
find some errors in patch 2/6, and i'm so sorry for
this.

thanks,
Duan

=D3=DA 2013/9/16 19:47, Duan Jiong =D0=B4=B5=C0:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>
> the ip6_redirect() could be replaced with
> ip6_redirect_no_header(), we could always use ip6_redirect()
> for route updating in ndisc layer and use the data of the
> redirected header option just for finding the socket to be
> notified and then notify user in protocols' err_handler.
>
> ---
>  Changes for v3:
>  1.del the ICMP6_INC_STATS_BH  error count, these are in fact
>    no errors.
>
>  Changes for v2:
>  1.handle the update of the NDISC_REDIRECT error code directly in
>    icmpv6_err_convert.
>  2.squash some patchs into one patch.
>  3.modify the subject of those patchs.
>
> Duan Jiong (6):
>   ipv6: del the statements for updating route in (dccp|tcp|sctp)_v6_e=
rr
>   ipv6: just match on ICMPV6_PKT_TOOBIG in those err_handle
>   ipv6: del statements for dealing with NDISC_REDIRECT
>   ip6tnl: move route updating for redirect to ndisc layer
>   ipv6: modify the err to 0 when dealing with NDISC_REDIRECT
>   ipv6: Do route updating for redirect in ndisc layer
>
>  include/net/ip6_route.h |  3 ---
>  net/dccp/ipv6.c         | 13 +------------
>  net/ipv6/ah6.c          |  9 ++-------
>  net/ipv6/esp6.c         |  9 ++-------
>  net/ipv6/icmp.c         |  5 +++--
>  net/ipv6/ip6_tunnel.c   |  5 -----
>  net/ipv6/ipcomp6.c      |  9 ++-------
>  net/ipv6/ndisc.c        |  6 ++----
>  net/ipv6/raw.c          |  3 +--
>  net/ipv6/route.c        | 29 ++---------------------------
>  net/ipv6/tcp_ipv6.c     | 12 ++++--------
>  net/ipv6/udp.c          |  2 --
>  net/sctp/input.c        | 12 ------------
>  net/sctp/ipv6.c         |  6 +++---
>  14 files changed, 22 insertions(+), 101 deletions(-)
>
