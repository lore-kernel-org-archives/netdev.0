From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V6 1/8] Drivers: hv: vmbus: add a helper function to set a
 channel's pending send size
Date: Tue, 26 Jan 2016 01:43:48 -0800
Message-ID: <1453801428-3241-1-git-send-email-decui@microsoft.com>
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

This will be used by the coming net/hvsock driver.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 include/linux/hyperv.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 753dbad..e4867a7 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -790,6 +790,12 @@ static inline void *get_per_channel_state(struct vmbus_channel *c)
 	return c->per_channel_state;
 }
 
+static inline void set_channel_pending_send_size(struct vmbus_channel *c,
+						 u32 size)
+{
+	c->outbound.ring_buffer->pending_send_sz = size;
+}
+
 void vmbus_onmessage(void *context);
 
 int vmbus_request_offers(void);
-- 
2.1.0
