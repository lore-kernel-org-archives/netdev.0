From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 11/21] wimax/i2400m: fix oops when the TX FIFO fills up due to a missing check
Date: Thu, 11 Jun 2009 14:35:48 -0700
Message-ID: <59063afa0afabc68d2b6ca0d106da9165e1c7d39.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28457 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756040AbZFKVgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:45 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the TX FIFO filled up and i2400m_tx_new() failed to allocate a
new TX message header, a missing check for said condition was causing a
kernel oops when trying to dereference a NULL i2400m->tx_msg pointer.

Found and diagnosed by Cindy H. Kao.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/tx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 4295dcf..fa16ccf 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -653,6 +653,8 @@ try_new:
 		i2400m_tx_close(i2400m);
 		i2400m_tx_new(i2400m);
 	}
+	if (i2400m->tx_msg == NULL)
+		goto error_tx_new;
 	if (i2400m->tx_msg->size + padded_len > I2400M_TX_BUF_SIZE / 2) {
 		d_printf(2, dev, "TX: message too big, going new\n");
 		i2400m_tx_close(i2400m);
-- 
1.6.2.3

