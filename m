From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 22/27] drivers/net/wan/z85230.c: fix sparse warnings:
	un-EXPORT symbols
Date: Mon, 22 Dec 2008 20:18:13 +0100
Message-ID: <20081222191813.11807.144.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756006AbYLVTSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:18:20 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The symbols are only references within the translation unit they are
defined in, so un-EXPORT them und make them 'static'.

Fix this sparse warnings:

  drivers/net/wan/z85230.c:604:25: warning: symbol 'z8530_dma_sync' was not declared. Should it be static?
  drivers/net/wan/z85230.c:613:25: warning: symbol 'z8530_txdma_sync' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wan/z85230.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index d7bf53a..3d00971 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -601,24 +601,18 @@ static void z8530_dma_status(struct z8530_channel *chan)
 	write_zsctrl(chan, RES_H_IUS);
 }
 
-struct z8530_irqhandler z8530_dma_sync=
-{
+static struct z8530_irqhandler z8530_dma_sync = {
 	z8530_dma_rx,
 	z8530_dma_tx,
 	z8530_dma_status
 };
 
-EXPORT_SYMBOL(z8530_dma_sync);
-
-struct z8530_irqhandler z8530_txdma_sync=
-{
+static struct z8530_irqhandler z8530_txdma_sync = {
 	z8530_rx,
 	z8530_dma_tx,
 	z8530_dma_status
 };
 
-EXPORT_SYMBOL(z8530_txdma_sync);
-
 /**
  *	z8530_rx_clear - Handle RX events from a stopped chip
  *	@c: Z8530 channel to shut up

