From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [RFC] xir2cps: use manf_id provided by the pcmcia core
Date: Sat, 17 Oct 2009 19:10:53 +0200
Message-ID: <20091017171053.GA24250@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:47335 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753187AbZJQRRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2009 13:17:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Sat, 17 Oct 2009 18:25:48 +0200
Subject: [PATCH 5/5] xir2cps: use manf_id provided by the pcmcia core

Instead of detecting it on its own, use the value provided by the pcmcia
core.

CC: netdev@vger.kernel.org
CC: David S. Miller <davem@davemloft.net>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/net/pcmcia/xirc2ps_cs.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index cf84231..c576eda 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -792,13 +792,12 @@ xirc2ps_config(struct pcmcia_device * link)
     tuple.TupleOffset = 0;
 
     /* Is this a valid	card */
-    tuple.DesiredTuple = CISTPL_MANFID;
-    if ((err=first_tuple(link, &tuple, &parse))) {
+    if (link->has_manf_id == 0) {
 	printk(KNOT_XIRC "manfid not found in CIS\n");
 	goto failure;
     }
 
-    switch(parse.manfid.manf) {
+    switch(link->manf_id) {
       case MANFID_XIRCOM:
 	local->manf_str = "Xircom";
 	break;
-- 
1.6.0.4

