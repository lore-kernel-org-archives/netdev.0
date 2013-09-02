From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH v2] drivers: net: ethernet: 8390: Kconfig: add H8300H_AKI3068NET
 and H8300H_H8MAX dependancy for NE_H8300
Date: Mon, 02 Sep 2013 10:20:02 +0800
Message-ID: <5223F5D2.7050504@asianux.com>
References: <522011A1.2080305@asianux.com> <20130830143639.GA16269@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>,
	Kees Cook <keescook@chromium.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:6571 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785Ab3IBCVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Sep 2013 22:21:07 -0400
In-Reply-To: <20130830143639.GA16269@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently only H8300H_AKI3068NET and H8300H_H8MAX define default
I/O base and IRQ values for the NE_H8300 driver.  Hence builds
for other H8300H platforms will fail as per below. Since H8300H
does not support multi platform builds, we simply limit building
the driver to those two platforms specifically.

The release error:

  drivers/net/ethernet/8390/ne-h8300.c: In function 'init_dev':
  drivers/net/ethernet/8390/ne-h8300.c:117:23: error: 'h8300_ne_base' undeclared (first use in this function)
  drivers/net/ethernet/8390/ne-h8300.c:117:23: note: each undeclared identifier is reported only once for each function it appears in
  drivers/net/ethernet/8390/ne-h8300.c:117:23: error: bit-field '<anonymous>' width not an integer constant
  drivers/net/ethernet/8390/ne-h8300.c:119:20: error: 'h8300_ne_irq' undeclared (first use in this function)
  drivers/net/ethernet/8390/ne-h8300.c: In function 'init_module':
  drivers/net/ethernet/8390/ne-h8300.c:647:21: error: 'h8300_ne_base' undeclared (first use in this function)
  drivers/net/ethernet/8390/ne-h8300.c:648:15: error: 'h8300_ne_irq' undeclared (first use in this function)
  drivers/net/ethernet/8390/ne-h8300.c:661:4: warning: format '%x' expects argument of type 'unsigned int', but argument 2 has type 'long unsigned int' [-Wformat]
 

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/net/ethernet/8390/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index a5f91e1..becef25 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -148,7 +148,7 @@ config PCMCIA_PCNET
 
 config NE_H8300
 	tristate "NE2000 compatible support for H8/300"
-	depends on H8300
+	depends on H8300H_AKI3068NET || H8300H_H8MAX
 	---help---
 	  Say Y here if you want to use the NE2000 compatible
 	  controller on the Renesas H8/300 processor.
-- 
1.7.7.6
