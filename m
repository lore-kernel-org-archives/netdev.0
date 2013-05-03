From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] asix: fix BUG in receive path when lowering MTU
Date: Fri, 03 May 2013 16:12:45 -0400 (EDT)
Message-ID: <20130503.161245.1218501153413968440.davem@davemloft.net>
References: <20130503112618.108645718@eitzenberger.org>
	<20130503113254.213946017@eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760627Ab3ECUMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:12:47 -0400
In-Reply-To: <20130503113254.213946017@eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: holger@eitzenberger.org
Date: Fri, 03 May 2013 12:02:20 +0200

> There is bug in the receive path of the asix driver at the time a
> packet is received larger than MTU size and DF bit set:
> 
>  BUG: unable to handle kernel paging request at 0000004000000001
>  IP: [<ffffffff8126f65b>] skb_release_head_state+0x2d/0xd2
>  ...
>  Call Trace:
>   <IRQ> 
>   [<ffffffff8126f86d>] ? skb_release_all+0x9/0x1e
>   [<ffffffff8126f8ad>] ? __kfree_skb+0x9/0x6f
>   [<ffffffffa00b4200>] ? asix_rx_fixup_internal+0xff/0x1ae [asix]
>   [<ffffffffa00fb3dc>] ? usbnet_bh+0x4f/0x226 [usbnet]
>   ...
> 
> It is easily reproducable by setting an MTU of 512 e. g. and sending
> something like
> 
>   ping -s 1472 -c 1 -M do $SELF
> 
> from another box.
> 
> And this is because the rx->ax_skb is freed on error, but rx->ax_skb
> is not reset, and the size is not reset to zero in this case.
> 
> And since the skb is added again to the usbnet->done skb queue it is
> accessing already freed memory, resulting in the BUG when freeing a
> 2nd time.  I therefore think the value 0x0000004000000001 show in the
> trace is more or less random data.
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Applied.
