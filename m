From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Fix gpio-mdio driver to work for gpio's that return something
	other than 0 and 1.
Date: Mon, 9 Nov 2009 19:02:19 +0000
Message-ID: <20091109190219.GB15159@caffeine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Len Sorensen <lsorense@csclub.uwaterloo.ca>,
	netdev@vger.kernel.org,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	Laurent Pinchart <laurentp@cse-semaphore.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:37582 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753627AbZKITCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 14:02:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gpio-mdio driver seems to assume GPIOs return 0 and 1, although that
doesn't seem to be the case.  I see return values of 0 and 0x1000000
for the GPIO I happen to be using.  A simple application of !! solves
that though.

Tested on a RuggedCom RX5000 (mpc8360e based).

Signed-off-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 8659d34..7e76f0c 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -55,7 +55,7 @@ static int mdio_get(struct mdiobb_ctrl *ctrl)
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
 
-	return gpio_get_value(bitbang->mdio);
+	return !!gpio_get_value(bitbang->mdio);
 }
 
 static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
