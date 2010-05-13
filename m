From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 6/20] drivers/net: Use kzalloc
Date: Thu, 13 May 2010 22:00:22 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005132200050.6282@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use kzalloc rather than the combination of kmalloc and memset.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x,size,flags;
statement S;
@@

-x = kmalloc(size,flags);
+x = kzalloc(size,flags);
 if (x == NULL) S
-memset(x, 0, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/mv643xx_eth.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -u -p a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2608,10 +2608,9 @@ static int mv643xx_eth_shared_probe(stru
 		goto out;
 
 	ret = -ENOMEM;
-	msp = kmalloc(sizeof(*msp), GFP_KERNEL);
+	msp = kzalloc(sizeof(*msp), GFP_KERNEL);
 	if (msp == NULL)
 		goto out;
-	memset(msp, 0, sizeof(*msp));
 
 	msp->base = ioremap(res->start, res->end - res->start + 1);
 	if (msp->base == NULL)
