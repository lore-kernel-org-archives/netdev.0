From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] Clean up sk_buff walkers
Date: Thu, 26 Apr 2007 00:38:35 -0700 (PDT)
Message-ID: <20070426.003835.45516098.davem@davemloft.net>
References: <200703200819.50363.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933185AbXDZHi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:38:28 -0400
In-Reply-To: <200703200819.50363.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jean Delvare <jdelvare@suse.de>
Date: Tue, 20 Mar 2007 08:19:49 +0100

> Hi all,
> 
> I noticed recently that, in skb_checksum(), "offset" and "start" are
> essentially the same thing and have the same value throughout the
> function, despite being computed differently. Using a single variable
> allows some cleanups and makes the skb_checksum() function smaller,
> more readable, and presumably marginally faster.
> 
> We appear to have many other "sk_buff walker" functions built on the
> exact same model, so the cleanup applies to them, too. Here is a list
> of the functions I found to be affected:
> 
> net/appletalk/ddp.c:atalk_sum_skb()
> net/core/datagram.c:skb_copy_datagram_iovec()
> net/core/datagram.c:skb_copy_and_csum_datagram()
> net/core/skbuff.c:skb_copy_bits()
> net/core/skbuff.c:skb_store_bits()
> net/core/skbuff.c:skb_checksum()
> net/core/skbuff.c:skb_copy_and_csum_bit()
> net/core/user_dma.c:dma_skb_copy_datagram_iovec()
> net/xfrm/xfrm_algo.c:skb_icv_walk()
> net/xfrm/xfrm_algo.c:skb_to_sgvec()
> 
> OTOH, I admit I'm a bit surprised, the cleanup is rather obvious so I'm
> really wondering if I am missing something. Can anyone please comment
> on this?
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Looks good, I've applied this patch.

Thanks!
