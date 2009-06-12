From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] ieee802154: fix kconfig bool/tristate muckup
Date: Fri, 12 Jun 2009 15:59:20 -0700
Message-ID: <4A32DDC8.7060605@oracle.com>
References: <20090611191420.1f4d5e4f.sfr@canb.auug.org.au> <4A31869B.3050901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4A31869B.3050901@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

menuconfig IEEE802154_DRIVERS is a bool that depends on tristate IEEE802154.
If the IEEE802154 symbol is 'm', the bool becomes 'y'.
This allows tristate symbols under IEEE802154_DRIVERS to be configured as
'y' and cause build problems.
Changing the menuconfig bool to a tristate fixes this.

drivers/built-in.o: In function `fake_scan_req':
fakehard.c:(.text+0x46d625): undefined reference to `ieee802154_nl_scan_confirm'
drivers/built-in.o: In function `fake_disassoc_req':
fakehard.c:(.text+0x46d66f): undefined reference to `ieee802154_nl_disassoc_confirm'
drivers/built-in.o: In function `fake_assoc_req':
fakehard.c:(.text+0x46d6be): undefined reference to `ieee802154_nl_assoc_confirm'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-zigbee-devel@lists.sourceforge.net
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: Sergey Lapin <slapin@ossfans.org>
---
 drivers/ieee802154/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20090612.orig/drivers/ieee802154/Kconfig
+++ linux-next-20090612/drivers/ieee802154/Kconfig
@@ -1,5 +1,5 @@
 menuconfig IEEE802154_DRIVERS
-	bool "IEEE 802.15.4 drivers"
+	tristate "IEEE 802.15.4 drivers"
 	depends on NETDEVICES && IEEE802154
 	default y
 	---help---


-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
