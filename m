From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 6/6] net: thunderx: Alloc higher order pages when pagesize is small
Date: Thu, 11 Feb 2016 21:50:26 +0530
Message-ID: <1455207626-35488-7-git-send-email-sunil.kovvuri@gmail.com>
References: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Allocate higher order pages when pagesize is small, this will
reduce number of calls to page allocator and wastage of memory.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 50ab6f4..5adb208 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -78,7 +78,7 @@ static void nicvf_free_q_desc_mem(struct nicvf *nic, struct q_desc_mem *dmem)
 static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, gfp_t gfp,
 					 u32 buf_len, u64 **rbuf)
 {
-	int order = get_order(buf_len);
+	int order = (PAGE_SIZE <= 4096) ?  PAGE_ALLOC_COSTLY_ORDER : 0;
 
 	/* Check if request can be accomodated in previous allocated page */
 	if (nic->rb_page) {
-- 
1.7.1
