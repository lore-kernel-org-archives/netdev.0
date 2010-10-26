From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 5/14] drivers/net/sb1000.c: delete double assignment
Date: Tue, 26 Oct 2010 12:25:34 +0200
Message-ID: <1288088743-3725-6-git-send-email-julia@diku.dk>
References: <1288088743-3725-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288088743-3725-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

The other code around these duplicated assignments initializes the 0 1 2
and 3 elements of an array, so change the initialization of the
rx_session_id array to do the same.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression i;
@@

*i = ...;
 i = ...;
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
This changes the semantics and has not been tested.

 drivers/net/sb1000.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index a9ae505..66c2f1a 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -961,9 +961,9 @@ sb1000_open(struct net_device *dev)
 	lp->rx_error_count = 0;
 	lp->rx_error_dpc_count = 0;
 	lp->rx_session_id[0] = 0x50;
-	lp->rx_session_id[0] = 0x48;
-	lp->rx_session_id[0] = 0x44;
-	lp->rx_session_id[0] = 0x42;
+	lp->rx_session_id[1] = 0x48;
+	lp->rx_session_id[2] = 0x44;
+	lp->rx_session_id[3] = 0x42;
 	lp->rx_frame_id[0] = 0;
 	lp->rx_frame_id[1] = 0;
 	lp->rx_frame_id[2] = 0;
