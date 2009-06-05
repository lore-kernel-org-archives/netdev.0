From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/5] ieee802154: add documentation about our stack
Date: Fri,  5 Jun 2009 06:29:49 +0400
Message-ID: <1244168990-28355-5-git-send-email-dbaryshkov@gmail.com>
References: <1244168990-28355-1-git-send-email-dbaryshkov@gmail.com>
 <1244168990-28355-2-git-send-email-dbaryshkov@gmail.com>
 <1244168990-28355-3-git-send-email-dbaryshkov@gmail.com>
 <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1244168990-28355-4-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add MAINTAINERS entry and a small text describing our stack interfaces,
how to hook the drivers, etc.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
---
 Documentation/networking/ieee802154.txt |   76 +++++++++++++++++++++++++++++++
 MAINTAINERS                             |   12 +++++
 2 files changed, 88 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/ieee802154.txt

diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
new file mode 100644
index 0000000..a0280ad
--- /dev/null
+++ b/Documentation/networking/ieee802154.txt
@@ -0,0 +1,76 @@
+
+		Linux IEEE 802.15.4 implementation
+
+
+Introduction
+============
+
+The Linux-ZigBee project goal is to provide complete implementation
+of IEEE 802.15.4 / ZigBee / 6LoWPAN protocols. IEEE 802.15.4 is a stack
+of protocols for organizing Low-Rate Wireless Personal Area Networks.
+
+Currently only IEEE 802.15.4 layer is implemented. We have choosen
+to use plain Berkeley socket API, the generic Linux networking stack
+to transfer IEEE 802.15.4 messages and a special protocol over genetlink
+for configuration/management
+
+
+Socket API
+==========
+
+int sd = socket(PF_IEEE802154, SOCK_DGRAM, 0);
+.....
+
+The address family, socket addresses etc. are defined in the
+include/net/ieee802154/af_ieee802154.h header or in the special header
+in our userspace package (see either linux-zigbee sourceforge download page
+or git tree at git://linux-zigbee.git.sourceforge.net/gitroot/linux-zigbee).
+
+One can use SOCK_RAW for passing raw data towards device xmit function. YMMV.
+
+
+MLME - MAC Level Management
+============================
+
+Most of IEEE 802.15.4 MLME interfaces are directly mapped on netlink commands.
+See the include/net/ieee802154/nl802154.h header. Our userspace tools package
+(see above) provides CLI configuration utility for radio interfaces and simple
+coordinator for IEEE 802.15.4 networks as an example users of MLME protocol.
+
+
+Kernel side
+=============
+
+Like with WiFi, there are several types of devices implementing IEEE 802.15.4.
+1) 'HardMAC'. The MAC layer is implemented in the device itself, the device
+   exports MLME and data API.
+2) 'SoftMAC' or just radio. These types of devices are just radio transceivers
+   possibly with some kinds of acceleration like automatic CRC computation and
+   comparation, automagic ACK handling, address matching, etc.
+
+Those types of devices require different approach to be hooked into Linux kernel.
+
+
+HardMAC
+=======
+
+See the header include/net/ieee802154/netdevice.h. You have to implement Linux
+net_device, with .type = ARPHRD_IEEE802154. Data is exchanged with socket family
+code via plain sk_buffs. The control block of sk_buffs will contain additional
+info as described in the struct ieee802154_mac_cb.
+
+To hook the MLME interface you have to populate the ml_priv field of your
+net_device with a pointer to struct ieee802154_mlme_ops instance. All fields are
+required.
+
+We provide an example of simple HardMAC driver at drivers/ieee802154/fakehard.c
+
+
+SoftMAC
+=======
+
+We are going to provide intermediate layer impelementing IEEE 802.15.4 MAC
+in software. This is currently WIP.
+
+See header include/net/ieee802154/mac802154.h and several drivers in
+drivers/ieee802154/
diff --git a/MAINTAINERS b/MAINTAINERS
index cf4abdd..a1bbc8f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2816,6 +2816,18 @@ L:	linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
 S:	Maintained
 F:	drivers/ieee1394/raw1394*
 
+IEEE 802.15.4 SUBSYSTEM
+P:	Dmitry Eremin-Solenikov
+M:	dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
+P:	Sergey Lapin
+M:	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org
+L:	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
+W:	http://apps.sourceforge.net/trac/linux-zigbee
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git
+S:	Maintained
+F:	net/ieee802154/
+F:	drivers/ieee801254/
+
 INTEGRITY MEASUREMENT ARCHITECTURE (IMA)
 P:	Mimi Zohar
 M:	zohar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
-- 
1.6.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
