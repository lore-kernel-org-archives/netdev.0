From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Use inline function dst_metric() instead of direct
 access to dst->metric[]
Date: Mon, 28 Apr 2008 23:10:17 +0900 (JST)
Message-ID: <20080428.231017.23295115.yoshfuji@linux-ipv6.org>
References: <d72b7ace0804250717g40f81ea0o899f43fdc1d08384@mail.gmail.com>
	<20080426.232332.30254129.davem@davemloft.net>
	<4815D81F.5090404@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: satoru.satoh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33865 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933167AbYD1OKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 10:10:14 -0400
In-Reply-To: <4815D81F.5090404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4815D81F.5090404@gmail.com> (at Mon, 28 Apr 2008 22:58:55 +0900), Satoru SATOH <satoru.satoh@gmail.com> says:

> 
> 
> There are functions to refer to the value of dst->metric[THE_METRIC-1] directly
> without use of a inline function "dst_metric" defined in net/dst.h.
> 
> The following patch changes them to use the inline function consistently.

Sato-san, I think we have more places, e.g., in net/ipv4/route.c:
    if (rt->u.dst.metrics[RTAX_HOPLIMIT-1] == 0)
should be converted as
    if (dst_metric(&rt->u.dst, RTAX_HOPLIMIT) == 0)

Could you annotate those as well, please?


Maybe we could introduce dst_metric_set(), but it is a
different issue.

--yoshfuji
