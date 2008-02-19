From: David Brownell <david-b@pacbell.net>
Subject: [RESEND/patch 2.6.25-rc2-git] net/enc28j60: section fix
Date: Tue, 19 Feb 2008 12:56:05 -0800
Message-ID: <200802191256.05570.david-b@pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200802062208.48838.david-b@pacbell.net> <47AAE7CD.9050801@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Claudio Lanconelli <lanconelli.claudio@eptar.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.sbc.mail.sp1.yahoo.com ([69.147.64.93]:30601 "HELO
	smtp120.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754654AbYBSU5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 15:57:19 -0500
In-Reply-To: <47AAE7CD.9050801@eptar.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor bugfixes to the enc28j60 driver ... wrong section marking,
indentation, and bogus use of spi_bus_type.  There's still major
overuse of printk; essentially every place it's used should switch
to dev_*() messaging primitives.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>
---
 drivers/net/enc28j60.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

--- a/drivers/net/enc28j60.c	2008-01-29 11:07:14.000000000 -0800
+++ b/drivers/net/enc28j60.c	2008-01-29 12:43:18.000000000 -0800
@@ -1555,7 +1555,7 @@ error_alloc:
 	return ret;
 }
 
-static int enc28j60_remove(struct spi_device *spi)
+static int __devexit enc28j60_remove(struct spi_device *spi)
 {
 	struct enc28j60_net *priv = dev_get_drvdata(&spi->dev);
 
@@ -1572,9 +1572,8 @@ static int enc28j60_remove(struct spi_de
 static struct spi_driver enc28j60_driver = {
 	.driver = {
 		   .name = DRV_NAME,
-		   .bus = &spi_bus_type,
 		   .owner = THIS_MODULE,
-		   },
+	 },
 	.probe = enc28j60_probe,
 	.remove = __devexit_p(enc28j60_remove),
 };
