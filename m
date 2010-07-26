From: Dan Carpenter <error27@gmail.com>
Subject: [patch] caif: handle snprintf() return
Date: Mon, 26 Jul 2010 09:23:59 +0200
Message-ID: <20100726072358.GK26313@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39939 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747Ab0GZHYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 03:24:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

snprintf() returns the number of bytes that would have been written.  It
can be larger than the size of the buffer.  The current code won't
overflow, but people cut and paste this stuff so lets do it right and
also make the static checkers happy.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 6c94803..f5058ff 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -165,6 +165,9 @@ static ssize_t dbgfs_state(struct file *file, char __user *user_buf,
 	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
 			"Next RX len: %d\n", cfspi->rx_npck_len);
 
+	if (len > DEBUGFS_BUF_SIZE)
+		len = DEBUGFS_BUF_SIZE;
+
 	size = simple_read_from_buffer(user_buf, count, ppos, buf, len);
 	kfree(buf);
 
