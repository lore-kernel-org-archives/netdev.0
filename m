From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] net: Cleanup redundant tests on unsigned
Date: Fri, 23 Oct 2009 17:21:56 +0200
Message-ID: <4AE1CA14.10304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Henner Eisen <eis@baty.hanse.de>, linux-x25@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-x25-owner@vger.kernel.org>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If there is data, the unsigned skb->len is greater than 0.

rt.sigdigits is unsigned as well, so the test `>= 0' is
always true, the other part of the test catches wrapped
values.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 net/x25/x25_in.c    |    2 +-
 net/x25/x25_route.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index 7d7c3ab..96d9227 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -114,7 +114,7 @@ static int x25_state1_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 			/*
 			 *	Copy any Call User Data.
 			 */
-			if (skb->len >= 0) {
+			if (skb->len > 0) {
 				skb_copy_from_linear_data(skb,
 					      x25->calluserdata.cuddata,
 					      skb->len);
diff --git a/net/x25/x25_route.c b/net/x25/x25_route.c
index 2c999cc..66961ea 100644
--- a/net/x25/x25_route.c
+++ b/net/x25/x25_route.c
@@ -190,7 +190,7 @@ int x25_route_ioctl(unsigned int cmd, void __user *arg)
 		goto out;
 
 	rc = -EINVAL;
-	if (rt.sigdigits < 0 || rt.sigdigits > 15)
+	if (rt.sigdigits > 15)
 		goto out;
 
 	dev = x25_dev_get(rt.device);
