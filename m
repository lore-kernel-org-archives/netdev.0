From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 5/8] drivers/atm/firestream.c: Fix unsigned return type
Date: Sun,  5 Sep 2010 21:00:23 +0200
Message-ID: <1283713226-8429-6-git-send-email-julia@diku.dk>
References: <1283713226-8429-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283713226-8429-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function has an unsigned return type, but returns a negative constant
to indicate an error condition.  The result of calling the function is
always stored in a variable of type (signed) int, and thus unsigned can be
dropped from the return type.

A sematic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@exists@
identifier f;
constant C;
@@

 unsigned f(...)
 { <+...
*  return -C;
 ...+> }
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/atm/firestream.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 8717809..1af977e 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -444,8 +444,8 @@ static inline void fs_kfree_skb (struct sk_buff * skb)
 #define ROUND_NEAREST 3
 /********** make rate (not quite as much fun as Horizon) **********/
 
-static unsigned int make_rate (unsigned int rate, int r,
-			       u16 * bits, unsigned int * actual) 
+static int make_rate(unsigned int rate, int r,
+		      u16 *bits, unsigned int *actual)
 {
 	unsigned char exp = -1; /* hush gcc */
 	unsigned int man = -1;  /* hush gcc */
