From: David Miller <davem@davemloft.net>
Subject: 2.6.24 net driver mis-patch
Date: Fri, 07 Dec 2007 23:43:43 -0800 (PST)
Message-ID: <20071207.234343.223864492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52916
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752400AbXLHHnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 02:43:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jeff, this belonged in netdev-2.6, Linus's tree doesn't have the BNX2X
driver yet, your 2.6.25 bound tree does.

As a result you added the ZLIB_INFLATE dependency to the TEHUTI driver
in 2.6.24 instead of BNX2X where it belongs, please fix this, thanks
:-)

commit 70eba18b5664f90d7620905e005b89388e5fd94b
Author: Eliezer Tamir <eliezert@broadcom.com>
Date:   Wed Dec 5 16:12:39 2007 +0200

    make bnx2x select ZLIB_INFLATE
    
    The bnx2x module depends on the zlib_inflate functions.  The
    build will fail if ZLIB_INFLATE has not been selected manually
    or by building another module that automatically selects it.
    
    Modify BNX2X config option to 'select ZLIB_INFLATE' like BNX2
    and others.  This seems to fix it.
    
    Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
    Acked-by: Eliezer Tamir <eliezert@broadcom.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d9107e5..6cde4ed 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2588,6 +2588,7 @@ config MLX4_DEBUG
 config TEHUTI
 	tristate "Tehuti Networks 10G Ethernet"
 	depends on PCI
+	select ZLIB_INFLATE
 	help
 	  Tehuti Networks 10G Ethernet NIC
 
