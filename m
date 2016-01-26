From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V6 2/8] Drivers: hv: vmbus: define the new offer type for
 Hyper-V socket (hvsock)
Date: Tue, 26 Jan 2016 01:44:15 -0800
Message-ID: <1453801455-3284-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, dan.carpenter@oracle.com, stefanha@redhat.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
 stephen@networkplumber.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
 vkuznets@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

A helper function is also added.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 include/linux/hyperv.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index e4867a7..c0eddd7 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -235,6 +235,7 @@ struct vmbus_channel_offer {
 #define VMBUS_CHANNEL_LOOPBACK_OFFER			0x100
 #define VMBUS_CHANNEL_PARENT_OFFER			0x200
 #define VMBUS_CHANNEL_REQUEST_MONITORED_NOTIFICATION	0x400
+#define VMBUS_CHANNEL_TLNPI_PROVIDER_OFFER		0x2000
 
 struct vmpacket_descriptor {
 	u16 type;
@@ -769,6 +770,12 @@ struct vmbus_channel {
 	enum hv_signal_policy  signal_policy;
 };
 
+static inline bool is_hvsock_channel(const struct vmbus_channel *c)
+{
+	return !!(c->offermsg.offer.chn_flags &
+		  VMBUS_CHANNEL_TLNPI_PROVIDER_OFFER);
+}
+
 static inline void set_channel_signal_state(struct vmbus_channel *c,
 					    enum hv_signal_policy policy)
 {
-- 
2.1.0
