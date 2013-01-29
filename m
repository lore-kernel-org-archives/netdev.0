From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next (v3)] ipv6: add anti-spoofing checks for 6to4
 and 6rd
Date: Tue, 29 Jan 2013 15:22:50 -0500 (EST)
Message-ID: <20130129.152250.2087385771449417394.davem@davemloft.net>
References: <20130129182425.GA30498@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab3A2UWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:22:51 -0500
In-Reply-To: <20130129182425.GA30498@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 29 Jan 2013 19:24:25 +0100

> This patch adds anti-spoofing checks in sit.c as specified in RFC3964
> section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
> checks which could easily be implemented with netfilter.
> 
> Specifically this patch adds following logic (based loosely on the
> pseudocode in RFC3964 section 5.2):
> 
> if prefix (inner_src_v6) == rd6_prefix (2002::/16 is the default)
>         and outer_src_v4 != embedded_ipv4 (inner_src_v6)
>                 drop
> if prefix (inner_dst_v6) == rd6_prefix (or 2002::/16 is the default)
>         and outer_dst_v4 != embedded_ipv4 (inner_dst_v6)
>                 drop
> accept
> 
> To accomplish the specified security checks proposed by above RFCs,
> it is still necessary to employ uRPF filters with netfilter. These new
> checks only kick in if the employed addresses are within the 2002::/16 or
> another range specified by the 6rd-prefix (which defaults to 2002::/16).
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
