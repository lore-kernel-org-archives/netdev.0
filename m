From: Ram.Natarajan@Emulex.Com
Subject: Using skb_get() to recycle skbs
Date: Thu, 25 Sep 2008 06:03:03 -0700
Message-ID: <A4114C1019D2F34CA5D6CDF8A4D1890178BEB834A0@EXMAIL.ad.emulex.com>
References: <20080922002153.GC1878@2ka.mipt.ru>
 <20080921.174450.20349529.davem@davemloft.net>
 <20080922010834.GB3059@2ka.mipt.ru>
 <20080921.190715.144340989.davem@davemloft.net>
 <20080922041929.GA20165@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emulex.emulex.com ([138.239.112.1]:40278 "EHLO
	emulex.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbYIYNDG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 09:03:06 -0400
Received: from xcm.ad.emulex.com (xcm.emulex.com [138.239.112.69])
	by emulex.emulex.com (8.13.6/8.13.6) with ESMTP id m8PD35f7028481
	for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 06:03:05 -0700 (PDT)
In-Reply-To: <20080922041929.GA20165@2ka.mipt.ru>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In our netdev driver, we preallocate a pool of skb which are
used by our h/w to DMA frames.

Normally, when we indicate a packet to stack (netif_rx),
the stack ends up freeing it. If we do a skb_get() prior
to that, then the stack just reduces the use_count,
and our driver is able to re-use it. We do have to use
caution to see that stack has dropped it's reference
(atomic_read(skb->users) <= 1) prior to returning
the buffer to our h/w.

Is this a valid approach? It so it could save some
CPU cycles which are used in alloc_skb(). If this
can be done, how come more drivers in tree are not
doing it, is there any flip side to it? One could be
that stack may not free it in time (we could starve
the hardware of free buffers), but in that case
we can drop our reference, and let the stack
free it up, and force an allocation instead of
reuse.

Thanks for your response.

Ram Natarajan
Emulex Corporation
