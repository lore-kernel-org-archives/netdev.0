From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH] myri10ge: fix rmmod crash
Date: Wed, 23 Mar 2011 13:44:30 +0100
Message-ID: <20110323124412.GA7813@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, Brice Goglin <brice@myri.com>,
        Andrew Gallatin <gallatin@myri.com>
To: netdev@vger.kernel.org
Return-path: <stable-bounces@linux.kernel.org>
Content-Disposition: inline
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

Rmmod myri10ge crash at free_netdev() -> netif_napi_del(), because napi
structures are already deallocated. To fix call netif_napi_del() before
kfree() at myri10ge_free_slices().

Cc: stable@kernel.org
Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/myri10ge/myri10ge.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index ea5cfe2..24386a8 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3645,6 +3645,7 @@ static void myri10ge_free_slices(struct myri10ge_priv *mgp)
 			dma_free_coherent(&pdev->dev, bytes,
 					  ss->fw_stats, ss->fw_stats_bus);
 			ss->fw_stats = NULL;
+			netif_napi_del(&ss->napi);
 		}
 	}
 	kfree(mgp->ss);
-- 
1.7.1

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
