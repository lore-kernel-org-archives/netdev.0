From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Tue, 17 Oct 2006 22:27:09 -0700 (PDT)
Message-ID: <20061017.222709.130237201.davem@davemloft.net>
References: <4415A4C1.1030906@cosmosbay.com>
	<452EA214.7080905@cosmosbay.com>
	<4535B6B7.4070107@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14025
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751380AbWJRF1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 01:27:03 -0400
To: dada1@cosmosbay.com
In-Reply-To: <4535B6B7.4070107@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 18 Oct 2006 07:08:07 +0200

> Each route entry includes a 'struct flow'. This structure has a
> current size of 80 bytes. This patch makes a size reduction
> depending on
> CONFIG_IPV6/CONFIG_IPV6_MODULE/CONFIG_DECNET/CONFIG_IP_ROUTE_FWMARK
> For a platform doing IPV4 only, the new size is 36 bytes (instead of
> 80) As many routers are base on PIII (L1_CACHE_SIZE=32), this saves
> one cache line per rtable entry.

I don't like these kinds of patches because %99 of people will never
ever realize the "savings" because distribution vendors will always,
unlaterally, enable everything.

For example, I'm still pending to cut the patch that kills the "struct
flow" from inet_sock's cork area since it really isn't needed.

I'd rather do things that get rid of the size in a way that benefits
everyone, regardless of kernel config.  I also would totally support
a patch that got rid of all the config ifdefs used in struct sk_buff.
