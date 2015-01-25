From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH 1/3 v2] hyperv: netvsc.c: match wait_for_completion_timeout
 return type
Date: Sun, 25 Jan 2015 15:46:31 +0100
Message-ID: <1422197191-7933-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 Nicholas Mc Guire <der.herr@hofr.at>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>
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

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---

v2: fixed subject line

The return type of wait_for_completion_timeout is unsigned long not
int. This patch fixes up the declarations only.

Patch was compile tested only for x86_64_defconfig + CONFIG_X86_VSMP=y
CONFIG_HYPERV=m, CONFIG_HYPERV_NET=m

Patch is against 3.19.0-rc5 -next-20150123

 drivers/net/hyperv/netvsc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 9f49c01..d2af032 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -217,7 +217,7 @@ static int netvsc_destroy_buf(struct netvsc_device *net_device)
 static int netvsc_init_buf(struct hv_device *device)
 {
 	int ret = 0;
-	int t;
+	unsigned long t;
 	struct netvsc_device *net_device;
 	struct nvsp_message *init_packet;
 	struct net_device *ndev;
@@ -409,7 +409,8 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 			      struct nvsp_message *init_packet,
 			      u32 nvsp_ver)
 {
-	int ret, t;
+	int ret;
+	unsigned long t;
 
 	memset(init_packet, 0, sizeof(struct nvsp_message));
 	init_packet->hdr.msg_type = NVSP_MSG_TYPE_INIT;
-- 
1.7.10.4
