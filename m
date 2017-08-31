From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Thu, 31 Aug 2017 13:47:02 +1000
Message-ID: <20170831134702.7fc1bd57@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Intiyaz Basha <intiyaz.basha@cavium.com>,
        Ying Huang <ying.huang@intel.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the tip tree got a conflict in:

  drivers/net/ethernet/cavium/liquidio/lio_main.c

between commit:

  d1d97ee6e3a8 ("liquidio: moved liquidio_napi_drv_callback to lio_core.c")

from the net-next tree and commit:

  966a967116e6 ("smp: Avoid using two cache lines for struct call_single_data")

from the tip tree.

I fixed it up (I added the blow merge fix patch) and can carry the fix
as necessary. This is now fixed as far as linux-next is concerned, but
any non trivial conflicts should be mentioned to your upstream maintainer
when your tree is submitted for merging.  You may also want to consider
cooperating with the maintainer of the conflicting tree to minimise any
particularly complex conflicts.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 31 Aug 2017 13:42:50 +1000
Subject: [PATCH] liquidio: fix for merge with "smp: Avoid using two cache
 lines for struct call_single_data"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 0e7896cdb295..23f6b60030c5 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -613,7 +613,7 @@ static void liquidio_napi_drv_callback(void *arg)
 	    droq->cpu_id == this_cpu) {
 		napi_schedule_irqoff(&droq->napi);
 	} else {
-		struct call_single_data *csd = &droq->csd;
+		call_single_data_t *csd = &droq->csd;
 
 		csd->func = napi_schedule_wrapper;
 		csd->info = &droq->napi;
-- 
2.13.2

-- 
Cheers,
Stephen Rothwell
