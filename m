From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] caif: fix NULL pointer check
Date: Tue, 24 Jul 2012 13:42:14 +0100
Message-ID: <20120724124207.4444.49789.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: sjur.brandeland@stericsson.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:45846 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801Ab2GXMZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 08:25:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

Reported-by: <rucsoftsec@gmail.com>
Resolves-bug: http://bugzilla.kernel.org/show_bug?44441
Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/caif/caif_serial.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 8a3054b..7e84175 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -325,6 +325,9 @@ static int ldisc_open(struct tty_struct *tty)
 
 	sprintf(name, "cf%s", tty->name);
 	dev = alloc_netdev(sizeof(*ser), name, caifdev_setup);
+	if (dev == NULL)
+		return -ENOMEM;
+
 	ser = netdev_priv(dev);
 	ser->tty = tty_kref_get(tty);
 	ser->dev = dev;
