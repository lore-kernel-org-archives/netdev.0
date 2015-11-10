From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] qed: select ZLIB_INFLATE
Date: Tue, 10 Nov 2015 11:28:15 +0100
Message-ID: <4747865.4UjGACl7bb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:54184 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbbKJK2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 05:28:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newly added qlogic qed driver uses the zlib library, but
misses the dependency:

drivers/built-in.o: In function `qed_alloc_stream_mem':
drivers/net/ethernet/qlogic/qed/qed_main.c:707: undefined reference to `zlib_inflate_workspacesize'
drivers/built-in.o: In function `qed_unzip_data':
drivers/net/ethernet/qlogic/qed/qed_main.c:675: undefined reference to `zlib_inflateInit2'

This changes Kconfig to always select zlib when needed.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: fe56b9e6a8d9 ("qed: Add module with basic common support")
---
Found on ARM randconfig builds

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 30a6f246dfc9..ddcfcab034c2 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -94,6 +94,7 @@ config NETXEN_NIC
 config QED
 	tristate "QLogic QED 25/40/100Gb core driver"
 	depends on PCI
+	select ZLIB_INFLATE
 	---help---
 	  This enables the support for ...
 
