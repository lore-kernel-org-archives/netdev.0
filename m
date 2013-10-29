From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb3: Fix length calculation in write_ofld_wr()
 on 32-bit architectures
Date: Tue, 29 Oct 2013 00:14:35 -0400 (EDT)
Message-ID: <20131029.001435.1010950710191845263.davem@davemloft.net>
References: <1382907759.2994.36.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645Ab3J2EOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 00:14:36 -0400
In-Reply-To: <1382907759.2994.36.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 27 Oct 2013 21:02:39 +0000

> The length calculation here is now invalid on 32-bit architectures,
> since sk_buff::tail is a pointer and sk_buff::transport_header is
> an integer offset:
> 
> drivers/net/ethernet/chelsio/cxgb3/sge.c: In function 'write_ofld_wr':
> drivers/net/ethernet/chelsio/cxgb3/sge.c:1603:9: warning: passing argument 4 of 'make_sgl' makes integer from pointer without a cast [enabled by default]
>          adap->pdev);
>          ^
> drivers/net/ethernet/chelsio/cxgb3/sge.c:964:28: note: expected 'unsigned int' but argument is of type 'sk_buff_data_t'
>  static inline unsigned int make_sgl(const struct sk_buff *skb,
>                             ^
> 
> Use the appropriate skb accessor functions.
> 
> Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Fixes: 1a37e412a022 ('net: Use 16bits for *_headers fields of struct skbuff')
> ---
> This is needed for 3.11-stable.

Applied and queued up for -stable, thanks Ben.
