From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net
 tree
Date: Sun, 28 Apr 2013 16:49:33 +0300
Message-ID: <20130428164933.6d3da501@lb-tlvb-yuvalmin.il.broadcom.com>
References: <20130426132447.c7b06622240088ccad366b03@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Ariel Elior" <ariele@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Stephen Rothwell" <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130426132447.c7b06622240088ccad366b03@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c between commit
> ecf01c22be03 ("bnx2x: Prevent NULL pointer dereference in kdump") from
> the net tree and commit 5b0752c863d7 ("bnx2x: Fix VF statistics") from
> the net-next tree.
> 
> I am not sure about this, but I just used the net tree version but I
> assume something more may be needed and can carry the fix as
> necessary (no action is required).
> 

Hi Stephen,

This patch adds the missing functionality from the `net-next' patch
which was lost due to the merge.

Is `linux-next' the correct tree to send it into?
(I couldn't designate it to `net-next' as the merge between `net' and
`net-next' hasn't occured yet, thus no collision there)

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c index
06dee5c..52cf71c 100644 ---
a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c +++
b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c @@ -6053,6 +6053,8
@@ void bnx2x_pre_irq_nic_init(struct bnx2x *bp) bnx2x_init_def_sb(bp);
 		bnx2x_update_dsb_idx(bp);
 		bnx2x_init_sp_ring(bp);
+	} else {
+		bnx2x_memset_stats(bp);
 	}
 }
 
-- 
1.8.1.227.g44fe835
