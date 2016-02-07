From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] bonding: Return correct error code
Date: Sun, 7 Feb 2016 10:56:25 +0530
Message-ID: <20160207052624.GA9263@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value of kzalloc on failure of allocation of memory should
be -ENOMEM and not -1.

Found using Coccinelle. A simplified version of the semantic patch
used is:

//<smpl>
@@
expression *e;
@@

e = kzalloc(...);
if (e == NULL) {
...
return
- -1
+ -ENOMEM
;
}
//</smpl>

The single call site only checks that the return value is not 0,
hence no change is required at the call site.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/bonding/bond_alb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index bb9e9fc..c5ac160 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -159,7 +159,7 @@ static int tlb_initialize(struct bonding *bond)
 
 	new_hashtbl = kzalloc(size, GFP_KERNEL);
 	if (!new_hashtbl)
-		return -1;
+		return -ENOMEM;
 
 	spin_lock_bh(&bond->mode_lock);
 
-- 
1.9.1
