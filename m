From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: [PATCH] Bluetooth: Fix BT_L2CAP and BT_SCO in Kconfig
Date: Fri, 25 Feb 2011 22:41:25 -0300
Message-ID: <1298684485-3081-1-git-send-email-padovan@profusion.mobi>
References: <20110226013639.GA2166@joana>
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110226013639.GA2166@joana>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If we want something "bool" built-in in something "tristate" it can't
"depend on" the tristate config option.

Report by DaveM:

   I give it 'y' just to make it happen, for both, and afterways no
   matter how many times I rerun "make oldconfig" I keep seeing things
   like this in my build:

scripts/kconfig/conf --silentoldconfig Kconfig
include/config/auto.conf:986:warning: symbol value 'm' invalid for BT_SCO
include/config/auto.conf:3156:warning: symbol value 'm' invalid for BT_L2CAP

Reported-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
---
 net/bluetooth/Kconfig |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
index c6f9c2f..6ae5ec5 100644
--- a/net/bluetooth/Kconfig
+++ b/net/bluetooth/Kconfig
@@ -31,9 +31,10 @@ menuconfig BT
 	  to Bluetooth kernel modules are provided in the BlueZ packages.  For
 	  more information, see <http://www.bluez.org/>.
 
+if BT != n
+
 config BT_L2CAP
 	bool "L2CAP protocol support"
-	depends on BT
 	select CRC16
 	help
 	  L2CAP (Logical Link Control and Adaptation Protocol) provides
@@ -42,11 +43,12 @@ config BT_L2CAP
 
 config BT_SCO
 	bool "SCO links support"
-	depends on BT
 	help
 	  SCO link provides voice transport over Bluetooth.  SCO support is
 	  required for voice applications like Headset and Audio.
 
+endif
+
 source "net/bluetooth/rfcomm/Kconfig"
 
 source "net/bluetooth/bnep/Kconfig"
-- 
1.7.4.1
