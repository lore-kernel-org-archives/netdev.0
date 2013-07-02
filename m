From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: ip6_append_data_mtu did not care about
 pmtudisc and frag_size
Date: Tue, 02 Jul 2013 12:45:14 -0700 (PDT)
Message-ID: <20130702.124514.1701303518493328527.davem@davemloft.net>
References: <20130702060405.GD9877@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231Ab3GBTpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 15:45:15 -0400
In-Reply-To: <20130702060405.GD9877@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 2 Jul 2013 08:04:05 +0200

> If the socket had an IPV6_MTU value set, ip6_append_data_mtu lost track
> of this when appending the second frame on a corked socket. This results
> in the following splat:
 ...
> While there, also check if path mtu discovery is activated for this
> socket. The logic was adapted from ip6_append_data when first writing
> on the corked socket.
> 
> This bug was introduced with commit
> 0c1833797a5a6ec23ea9261d979aa18078720b74 ("ipv6: fix incorrect ipsec
> fragment").
> 
> v2:
> a) Replace IPV6_PMTU_DISC_DO with IPV6_PMTUDISC_PROBE.
> b) Don't pass ipv6_pinfo to ip6_append_data_mtu (suggestion by Gao
>    feng, thanks!).
> c) Change mtu to unsigned int, else we get a warning about
>    non-matching types because of the min()-macro type-check.
> 
> Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable.
