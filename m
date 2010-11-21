From: Joe Perches <joe@perches.com>
Subject: [PATCH 43/62] tokenring: Use static const
Date: Sat, 20 Nov 2010 18:38:44 -0800
Message-ID: <b55a96baa14091337ec25c9b153a9aac42bab384.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  21834	    549	   5144	  27527	   6b87	drivers/net/tokenring/ibmtr.o.old
  21834	    549	   5144	  27527	   6b87	drivers/net/tokenring/ibmtr.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tokenring/ibmtr.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 91e6c78..4786497 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -657,8 +657,9 @@ static int __devinit ibmtr_probe1(struct net_device *dev, int PIOaddr)
 #ifndef PCMCIA
 	/* finish figuring the shared RAM address */
 	if (cardpresent == TR_ISA) {
-		static __u32 ram_bndry_mask[] =
-			{ 0xffffe000, 0xffffc000, 0xffff8000, 0xffff0000 };
+		static const __u32 ram_bndry_mask[] = {
+			0xffffe000, 0xffffc000, 0xffff8000, 0xffff0000
+		};
 		__u32 new_base, rrr_32, chk_base, rbm;
 
 		rrr_32=readb(ti->mmio+ACA_OFFSET+ACA_RW+RRR_ODD) >> 2 & 0x03;
-- 
1.7.3.2.245.g03276.dirty
