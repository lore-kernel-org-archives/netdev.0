From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V3 1/7] Drivers: hv: vmbus: define the new offer type for Hyper-V  socket (hvsock)
Date: Tue, 21 Jul 2015 03:57:52 -0700
Message-ID: <1437476272-6769-1-git-send-email-decui@microsoft.com>
To: gregkh@linuxfoundation.org, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	pebolle@tiscali.nl, stefanha@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A helper function is also added.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 include/linux/hyperv.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 30d3a1f..2ca3ac1 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -236,6 +236,7 @@ struct vmbus_channel_offer {
 #define VMBUS_CHANNEL_LOOPBACK_OFFER			0x100
 #define VMBUS_CHANNEL_PARENT_OFFER			0x200
 #define VMBUS_CHANNEL_REQUEST_MONITORED_NOTIFICATION	0x400
+#define VMBUS_CHANNEL_TLNPI_PROVIDER_OFFER		0x2000
 
 struct vmpacket_descriptor {
 	u16 type;
@@ -758,6 +759,12 @@ struct vmbus_channel {
 	struct list_head percpu_list;
 };
 
+static inline bool is_hvsock_channel(const struct vmbus_channel *c)
+{
+	return !!(c->offermsg.offer.chn_flags &
+		  VMBUS_CHANNEL_TLNPI_PROVIDER_OFFER);
+}
+
 static inline void set_channel_read_state(struct vmbus_channel *c, bool state)
 {
 	c->batched_reading = state;
-- 
2.1.0
