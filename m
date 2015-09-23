From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/7] 8139cp: Improve accuracy of cp_interrupt() return,
 to survive IRQ storms
Date: Thu, 24 Sep 2015 01:29:31 +0200
Message-ID: <20150923232931.GA8365@electric-eye.fr.zoreil.com>
References: <1442996049.36485.32.camel@infradead.org>
 <20150923.105812.149257816141624869.davem@davemloft.net>
 <1443037530.74600.29.camel@infradead.org>
 <20150923.144808.886375927698238398.davem@davemloft.net>
 <1443045602.74600.33.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48255 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901AbbIWXce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:32:34 -0400
Content-Disposition: inline
In-Reply-To: <1443045602.74600.33.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> Great, thanks. I've got one more for the net tree; just masking the
> gso_size to the maximum (0xfff) that the hardware can handle, and never
> telling the net stack that that's our maximum, doesn't seem like such a
> good idea...

0xfff, really ?

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index d79e33b..8c6811d 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -174,7 +180,7 @@ enum {
 	LastFrag	= (1 << 28), /* Final segment of a packet */
 	LargeSend	= (1 << 27), /* TCP Large Send Offload (TSO) */
 	MSSShift	= 16,	     /* MSS value position */
-	MSSMask		= 0xfff,     /* MSS value: 11 bits */
+	MSSMask		= 0x7ff,     /* MSS value: 11 bits */
 	TxError		= (1 << 23), /* Tx error summary */
 	RxError		= (1 << 20), /* Rx error summary */
 	IPCS		= (1 << 18), /* Calculate IP checksum */
-- 
Ueimor
