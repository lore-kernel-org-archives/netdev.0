From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/4] tun/tap: use paren's with sizeof
Date: Tue, 15 Aug 2017 10:29:16 -0700
Message-ID: <20170815172919.26153-2-sthemmin@microsoft.com>
References: <20170815172919.26153-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <sthemmin@microsoft.com>,
	virtualization@lists.linux-foundation.org
To: mlindner@marvell.com, stephen@networkplumber.org, mst@redhat.com,
	jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170815172919.26153-1-sthemmin@microsoft.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Although sizeof is an operator in C. The kernel coding style convention
is to always use it like a function and add parenthesis.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/tap.c | 2 +-
 drivers/net/tun.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 0d039411e64c..21b71ae947fd 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -1215,7 +1215,7 @@ int tap_queue_resize(struct tap_dev *tap)
 	int n = tap->numqueues;
 	int ret, i = 0;
 
-	arrays = kmalloc(sizeof *arrays * n, GFP_KERNEL);
+	arrays = kmalloc_array(n, sizeof(*arrays), GFP_KERNEL);
 	if (!arrays)
 		return -ENOMEM;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 5892284eb8d0..f5017121cd57 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2737,7 +2737,7 @@ static int tun_queue_resize(struct tun_struct *tun)
 	int n = tun->numqueues + tun->numdisabled;
 	int ret, i;
 
-	arrays = kmalloc(sizeof *arrays * n, GFP_KERNEL);
+	arrays = kmalloc_array(n, sizeof(*arrays), GFP_KERNEL);
 	if (!arrays)
 		return -ENOMEM;
 
-- 
2.11.0
