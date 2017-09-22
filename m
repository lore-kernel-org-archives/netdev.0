From: Colin King <colin.king@canonical.com>
Subject: [PATCH] hv_netvsc:  make const array ver_list static,
 reduces object code size
Date: Fri, 22 Sep 2017 16:50:23 +0100
Message-ID: <20170922155023.15821-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "K . Y . Srinivasan" <kys@microsoft.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 Stephen Hemminger <sthemmin@microsoft.com>, devel@linuxdriverproject.org,
 netdev@vger.kernel.org
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

From: Colin Ian King <colin.king@canonical.com>

Don't populate const array ver_list on the stack, instead make it
static. Makes the object code smaller by over 400 bytes:

Before:
   text	   data	    bss	    dec	    hex	filename
  18444	   3168	    320	  21932	   55ac	drivers/net/hyperv/netvsc.o

After:
   text	   data	    bss	    dec	    hex	filename
  17950	   3224	    320	  21494	   53f6	drivers/net/hyperv/netvsc.o

(gcc 6.3.0, x86-64)

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/hyperv/netvsc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 8d5077fb0492..b0d323e24978 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -484,7 +484,7 @@ static int netvsc_connect_vsp(struct hv_device *device,
 			      struct netvsc_device *net_device,
 			      const struct netvsc_device_info *device_info)
 {
-	const u32 ver_list[] = {
+	static const u32 ver_list[] = {
 		NVSP_PROTOCOL_VERSION_1, NVSP_PROTOCOL_VERSION_2,
 		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5
 	};
-- 
2.14.1
