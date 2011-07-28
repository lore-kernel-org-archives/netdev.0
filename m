From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 3/6] drivers/net/niu.c: adjust array index
Date: Thu, 28 Jul 2011 14:46:03 +0200
Message-ID: <1311857165-14780-4-git-send-email-julia@diku.dk>
References: <1311857165-14780-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311857165-14780-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Convert array index from the loop bound to the loop index.

A simplified version of the semantic patch that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e1,e2,ar;
@@

for(e1 = 0; e1 < e2; e1++) { <...
  ar[
- e2
+ e1
  ]
  ...> }
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
Not tested.

 drivers/net/niu.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -u -p a/drivers/net/niu.c b/drivers/net/niu.c
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -9201,7 +9201,7 @@ static int __devinit niu_ldg_init(struct
 
 	first_chan = 0;
 	for (i = 0; i < port; i++)
-		first_chan += parent->rxchan_per_port[port];
+		first_chan += parent->rxchan_per_port[i];
 	num_chan = parent->rxchan_per_port[port];
 
 	for (i = first_chan; i < (first_chan + num_chan); i++) {
@@ -9217,7 +9217,7 @@ static int __devinit niu_ldg_init(struct
 
 	first_chan = 0;
 	for (i = 0; i < port; i++)
-		first_chan += parent->txchan_per_port[port];
+		first_chan += parent->txchan_per_port[i];
 	num_chan = parent->txchan_per_port[port];
 	for (i = first_chan; i < (first_chan + num_chan); i++) {
 		err = niu_ldg_assign_ldn(np, parent,
