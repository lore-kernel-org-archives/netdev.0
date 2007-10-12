From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH net-2.6] uml: hard_header fix
Date: Fri, 12 Oct 2007 11:06:45 -0700
Message-ID: <20071012110645.4e7622af@freepuppy.rosehill>
References: <20071011213126.cf92efb7.akpm@linux-foundation.org>
	<20071012140328.f82af8e8.kamezawa.hiroyu@jp.fujitsu.com>
	<20071011234202.2f15bb76.akpm@linux-foundation.org>
	<20071012064658.GA8181@ftp.linux.org.uk>
	<20071012001325.ba02a6f0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761962AbXJLSHV@vger.kernel.org>
In-Reply-To: <20071012001325.ba02a6f0.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix hard_header for net-2.6 (2.6.23-mm1).

Please test this patch, unfortunately the tree it came from won't
build UML, so it isn't possible to give it a proper check.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/arch/um/drivers/slip_kern.c	2007-10-11 13:16:07.000000000 -0700
+++ b/arch/um/drivers/slip_kern.c	2007-10-12 11:06:00.000000000 -0700
@@ -30,9 +30,7 @@ void slip_init(struct net_device *dev, v
 	slip_proto_init(&spri->slip);
 
 	dev->init = NULL;
-	dev->header_cache_update = NULL;
-	dev->hard_header_cache = NULL;
-	dev->hard_header = NULL;
+	dev->hard_header_ops = NULL;
 	dev->hard_header_len = 0;
 	dev->addr_len = 0;
 	dev->type = ARPHRD_SLIP;
--- a/arch/um/drivers/slirp_kern.c	2007-10-11 13:16:07.000000000 -0700
+++ b/arch/um/drivers/slirp_kern.c	2007-10-12 11:05:52.000000000 -0700
@@ -31,9 +31,7 @@ void slirp_init(struct net_device *dev, 
 
 	dev->init = NULL;
 	dev->hard_header_len = 0;
-	dev->header_cache_update = NULL;
-	dev->hard_header_cache = NULL;
-	dev->hard_header = NULL;
+	dev->hard_header_ops = NULL;
 	dev->addr_len = 0;
 	dev->type = ARPHRD_SLIP;
 	dev->tx_queue_len = 256;
