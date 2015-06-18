From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] NET: ROSE: Don't dereference NULL neighbour pointer.
Date: Fri, 19 Jun 2015 00:46:53 +0200
Message-ID: <20150618224652.GB17494@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, stable@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A ROSE socket doesn't necessarily always have a neighbour pointer so check
if the neighbour pointer is valid before dereferencing it.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Tested-by: Bernard Pidoux <f6bvp@free.fr>
Cc: stable@vger.kernel.org #2.6.11+

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 8ae6030..dd304bc 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -192,7 +192,8 @@ static void rose_kill_by_device(struct net_device *dev)
 
 		if (rose->device == dev) {
 			rose_disconnect(s, ENETUNREACH, ROSE_OUT_OF_ORDER, 0);
-			rose->neighbour->use--;
+			if (rose->neighbour)
+				rose->neighbour->use--;
 			rose->device = NULL;
 		}
 	}
