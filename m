From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 08/10] netvsc: remove unnecessary check for NULL hdr
Date: Wed,  9 Aug 2017 17:46:10 -0700
Message-ID: <20170810004612.22163-9-sthemmin@microsoft.com>
References: <20170810004612.22163-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170810004612.22163-1-sthemmin@microsoft.com>
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

The function init_page_array is always called with a valid pointer
to RNDIS header. No check for NULL is needed.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 9f89de17b5fa..7b465e40869b 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -333,10 +333,9 @@ static u32 init_page_array(void *hdr, u32 len, struct sk_buff *skb,
 	 * 2. skb linear data
 	 * 3. skb fragment data
 	 */
-	if (hdr != NULL)
-		slots_used += fill_pg_buf(virt_to_page(hdr),
-					offset_in_page(hdr),
-					len, &pb[slots_used]);
+	slots_used += fill_pg_buf(virt_to_page(hdr),
+				  offset_in_page(hdr),
+				  len, &pb[slots_used]);
 
 	packet->rmsg_size = len;
 	packet->rmsg_pgcnt = slots_used;
-- 
2.11.0
