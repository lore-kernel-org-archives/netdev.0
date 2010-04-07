From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] CAIF: write check
Date: Wed, 7 Apr 2010 14:17:03 +0100
Message-ID: <20100407141703.7c0a4a65@lxorguk.ukuu.org.uk>
References: <20100401160916.2a2574f4@lxorguk.ukuu.org.uk>
	<81C3A93C17462B4BBD7E272753C105791696B5DCF0@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:57679 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757943Ab0DGNM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 09:12:58 -0400
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791696B5DCF0@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

caif: check write operations

From: Alan Cox <alan@linux.intel.com>

write is optional for a tty device. Check that we have a write op rather
than calling NULL.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/caif/caif_serial.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)


diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index b271aa0..38c0186 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -312,6 +312,10 @@ static int ldisc_open(struct tty_struct *tty)
 	char name[64];
 	int result;
 
+	/* No write no play */
+	if (tty->ops->write == NULL)
+		return -EOPNOTSUPP;
+
 	sprintf(name, "cf%s", tty->name);
 	dev = alloc_netdev(sizeof(*ser), name, caifdev_setup);
 	ser = netdev_priv(dev);

