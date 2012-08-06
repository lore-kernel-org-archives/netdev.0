From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: pch_gbe: dont-copy-payload (was [PATCH 1/4] ...)
Date: Mon, 06 Aug 2012 16:52:36 +0200
Message-ID: <1344264756.26674.19.camel@edumazet-glaptop>
References: <40680C535D6FE6498883F1640FACD44D011432D4@ka-exchange-1.kontronamerica.local>
	 <1342508968.2626.148.camel@edumazet-glaptop>
	 <1342510387.2626.174.camel@edumazet-glaptop>
	 <40680C535D6FE6498883F1640FACD44D011BBE1D@ka-exchange-1.kontronamerica.local>
	 <40680C535D6FE6498883F1640FACD44D0122CF12@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Cress <andy.cress@us.kontron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35217 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab2HFOwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 10:52:46 -0400
Received: by bkwj10 with SMTP id j10so1064467bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 07:52:45 -0700 (PDT)
In-Reply-To: <40680C535D6FE6498883F1640FACD44D0122CF12@ka-exchange-1.kontronamerica.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 07:19 -0700, Andy Cress wrote:
> I found out why the proposed dont-copy-payload patch didn't work with
> this pch_gbe NIC.
> This NIC PHY requires 64-byte-aligned DMA, and the transmit buffers
> won't be transferred if skb->data is not 64-byte-aligned.  Apparently
> the data copy has a by-product of aligning the buffers.  
> 
> I tried using skb_reserve(skb,64) in pch_gbe_alloc_tx_buffers and
> pch-gbe_alloc_rx_buffers, but that didn't seem to resolve it.
> 
> How can I make sure that the transmit data buffers are
> 64-byte-aligned?
> 

There is no support for such requirement in linux stacks.

Only solution for the driver is to copy all frames to 64-byte-aligned
bounce buffers.
