From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 11/12] net/netlabel: Correct redundant test
Date: Mon, 27 Jul 2009 18:15:43 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907271815260.2682@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: paul.moore@hp.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753181AbZG0QTP@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

entry was tested for NULL near the beginning of the function, followed by a
return, and there is no intervening modification of its value.

A simplified version of the semantic match that finds this problem is as
follows: (http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@r exists@
local idexpression x;
expression E;
position p1,p2;
@@

if (x == NULL || ...) { ... when forall
   return ...; }
... when != \(x=E\|x--\|x++\|--x\|++x\|x-=E\|x+=E\|x|=E\|x&=E\|&x\)
(
*x == NULL
|
*x != NULL
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/netlabel/netlabel_kapi.c        |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index b0e582f..3ff6f32 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -185,8 +185,7 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 	return 0;
 
 cfg_unlbl_map_add_failure:
-	if (entry != NULL)
-		kfree(entry->domain);
+	kfree(entry->domain);
 	kfree(entry);
 	kfree(addrmap);
 	kfree(map4);
@@ -385,8 +384,7 @@ int netlbl_cfg_cipsov4_map_add(u32 doi,
 
 cfg_cipsov4_map_add_failure:
 	cipso_v4_doi_putdef(doi_def);
-	if (entry != NULL)
-		kfree(entry->domain);
+	kfree(entry->domain);
 	kfree(entry);
 	kfree(addrmap);
 	kfree(addrinfo);
