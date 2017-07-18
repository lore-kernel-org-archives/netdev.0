From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] liquidio: lio_main: remove unnecessary static in
 setup_io_queues()
Date: Tue, 18 Jul 2017 15:53:48 -0500
Message-ID: <20170718205348.GA25613@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway20.websitewelcome.com ([192.185.65.13]:29363 "EHLO
        gateway20.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751465AbdGRUxt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 16:53:49 -0400
Received: from cm16.websitewelcome.com (cm16.websitewelcome.com [100.42.49.19])
        by gateway20.websitewelcome.com (Postfix) with ESMTP id 932224012AFDF
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 15:53:49 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary static on local variables cpu_id_modulus and cpu_id.
Such variables are initialized before being used, on every execution
path throughout the function. The static has no benefit and, removing
it reduces the object file size.

This issue was detected using Coccinelle and the following semantic patch:

@bad exists@
position p;
identifier x;
type T;
@@

static T x@p;
...
x = <+...x...+>

@@
identifier x;
expression e;
type T;
position p != bad.p;
@@

-static
 T x@p;
 ... when != x
     when strict
?x = e;

In the following log you can see a significant difference in the object
file size. Also, there is a significant difference in the bss segment.
This log is the output of the size command, before and after the code
change:

before:
   text    data     bss     dec     hex filename
  78689   15272   27808  121769   1dba9 drivers/net/ethernet/cavium/liquidio/lio_main.o

after:
   text    data     bss     dec     hex filename
  78667   15128   27680  121475   1da83 drivers/net/ethernet/cavium/liquidio/lio_main.o

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 51583ae..1d8fefa 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2544,8 +2544,8 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 {
 	struct octeon_droq_ops droq_ops;
 	struct net_device *netdev;
-	static int cpu_id;
-	static int cpu_id_modulus;
+	int cpu_id;
+	int cpu_id_modulus;
 	struct octeon_droq *droq;
 	struct napi_struct *napi;
 	int q, q_no, retval = 0;
-- 
2.5.0
