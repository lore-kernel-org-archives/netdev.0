From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 02/10] netvsc: don't signal host twice if empty
Date: Wed,  9 Aug 2017 17:46:04 -0700
Message-ID: <20170810004612.22163-3-sthemmin@microsoft.com>
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

When hv_pkt_iter_next() returns NULL, it has already called
hv_pkt_iter_close(). Calling it twice can lead to extra host signal.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 208f03aa83de..c842265d1df9 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1190,10 +1190,6 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 		nvchan->desc = hv_pkt_iter_next(channel, nvchan->desc);
 	}
 
-	/* if ring is empty, signal host */
-	if (!nvchan->desc)
-		hv_pkt_iter_close(channel);
-
 	/* If send of pending receive completions suceeded
 	 *   and did not exhaust NAPI budget this time
 	 *   and not doing busy poll
-- 
2.11.0
