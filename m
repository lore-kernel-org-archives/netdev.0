From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 14/14 v2]
	Documentation/networking/ieee802154: update MAC chapter
Date: Mon, 26 Dec 2011 20:13:15 +0300
Message-ID: <1324919595-15318-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Update the documentation according to latest changes.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/networking/ieee802154.txt |   75 ++++++++++++++++++++++++-------
 1 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
index 1dc1c24..703cf43 100644
--- a/Documentation/networking/ieee802154.txt
+++ b/Documentation/networking/ieee802154.txt
@@ -4,15 +4,22 @@
 
 Introduction
 ============
+The IEEE 802.15.4 working group focuses on standartization of bottom
+two layers: Medium Accsess Control (MAC) and Physical (PHY). And there
+are mainly two options available for upper layers:
+ - ZigBee - proprietary protocol from ZigBee Alliance
+ - 6LowPAN - IPv6 networking over low rate personal area networks
 
 The Linux-ZigBee project goal is to provide complete implementation
-of IEEE 802.15.4 / ZigBee / 6LoWPAN protocols. IEEE 802.15.4 is a stack
+of IEEE 802.15.4 and 6LoWPAN protocols. IEEE 802.15.4 is a stack
 of protocols for organizing Low-Rate Wireless Personal Area Networks.
 
-Currently only IEEE 802.15.4 layer is implemented. We have chosen
-to use plain Berkeley socket API, the generic Linux networking stack
-to transfer IEEE 802.15.4 messages and a special protocol over genetlink
-for configuration/management
+The stack is composed of three main parts:
+ - IEEE 802.15.4 layer;  We have chosen to use plain Berkeley socket API,
+   the generic Linux networking stack to transfer IEEE 802.15.4 messages
+   and a special protocol over genetlink for configuration/management
+ - MAC - provides access to shared channel and reliable data delivery
+ - PHY - represents device drivers
 
 
 Socket API
@@ -29,15 +36,6 @@ or git tree at git://linux-zigbee.git.sourceforge.net/gitroot/linux-zigbee).
 One can use SOCK_RAW for passing raw data towards device xmit function. YMMV.
 
 
-MLME - MAC Level Management
-============================
-
-Most of IEEE 802.15.4 MLME interfaces are directly mapped on netlink commands.
-See the include/net/nl802154.h header. Our userspace tools package
-(see above) provides CLI configuration utility for radio interfaces and simple
-coordinator for IEEE 802.15.4 networks as an example users of MLME protocol.
-
-
 Kernel side
 =============
 
@@ -51,6 +49,15 @@ Like with WiFi, there are several types of devices implementing IEEE 802.15.4.
 Those types of devices require different approach to be hooked into Linux kernel.
 
 
+MLME - MAC Level Management
+============================
+
+Most of IEEE 802.15.4 MLME interfaces are directly mapped on netlink commands.
+See the include/net/nl802154.h header. Our userspace tools package
+(see above) provides CLI configuration utility for radio interfaces and simple
+coordinator for IEEE 802.15.4 networks as an example users of MLME protocol.
+
+
 HardMAC
 =======
 
@@ -73,11 +80,47 @@ We provide an example of simple HardMAC driver at drivers/ieee802154/fakehard.c
 SoftMAC
 =======
 
-We are going to provide intermediate layer implementing IEEE 802.15.4 MAC
-in software. This is currently WIP.
+The MAC is the middle layer in the IEEE 802.15.4 Linux stack. This moment it
+provides interface for drivers registration and management of slave interfaces.
+
+NOTE: Currently the only monitor device type is supported - it's IEEE 802.15.4
+stack interface for network sniffers (e.g. WireShark).
+
+This layer is going to be extended soon.
 
 See header include/net/mac802154.h and several drivers in drivers/ieee802154/.
 
+
+Device drivers API
+==================
+
+The include/net/mac802154.h defines following functions:
+ - struct ieee802154_dev *ieee802154_alloc_device
+   (size_t priv_size, struct ieee802154_ops *ops):
+   allocation of IEEE 802.15.4 compatible device
+
+ - void ieee802154_free_device(struct ieee802154_dev *dev):
+   freeing allocated device
+
+ - int ieee802154_register_device(struct ieee802154_dev *dev):
+   register PHY in the system
+
+ - void ieee802154_unregister_device(struct ieee802154_dev *dev):
+   freeing registered PHY
+
+Moreover IEEE 802.15.4 device operations structure should be filled.
+
+Fake drivers
+============
+
+In addition there are two drivers available which simulate real devices with
+HardMAC (fakehard) and SoftMAC (fakelb - IEEE 802.15.4 loopback driver)
+interfaces. This option provides possibility to test and debug stack without
+usage of real hardware.
+
+See sources in drivers/ieee802154 folder for more details.
+
+
 6LoWPAN Linux implementation
 ============================
 
-- 
1.7.2.3


------------------------------------------------------------------------------
Write once. Port to many.
Get the SDK and tools to simplify cross-platform app development. Create 
new or port existing apps to sell to consumers worldwide. Explore the 
Intel AppUpSM program developer opportunity. appdeveloper.intel.com/join
http://p.sf.net/sfu/intel-appdev
