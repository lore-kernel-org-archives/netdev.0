From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2] IPv6: fix bug when specifying the non-exist outgoing
 interface
Date: Mon, 02 Jun 2008 13:39:10 -0400
Message-ID: <4844303E.1040104@hp.com>
References: <20080603.014105.73332390.yoshfuji@linux-ipv6.org>	<20080603.014604.26891059.yoshfuji@linux-ipv6.org>	<20080603.014819.38527291.yoshfuji@linux-ipv6.org> <20080603.020734.75959629.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:20206 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758607AbYFBRjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 13:39:12 -0400
In-Reply-To: <20080603.020734.75959629.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 wrote:
> -			if (addr_type == IPV6_ADDR_ANY)
> +			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
> +			if (addr_type == IPV6_ADDR_ANY ||
> +			    addr_type & IPV6_ADDR_MULTICAST) {
> +				if (dev)
> +					dev_put(dev);
>  				break;

What about link-local multicast?  We should check ifindex there too.  I
think that check should just be for IPV6_ADDR_ANY.  I think making this
more like inet6_bind() and not doing the ipv6_chk_addr() call for
Multicast would be the best thing, right?

-Brian
