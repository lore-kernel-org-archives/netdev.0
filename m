From: Kumar Gala <galak@kernel.crashing.org>
Subject: Please pull from 'from_linus' branch
Date: Fri, 29 Jun 2007 00:13:46 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0706290012430.15686@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	acme@redhat.com
To: Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52567 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbXF2FOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 01:14:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from 'for_linus' branch of

	master.kernel.org:/pub/scm/linux/kernel/git/galak/powerpc.git for_linus

to receive the following updates:

 drivers/net/gianfar.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Kumar Gala (1):
      gianfar: Fix typo bug introduced by move to udp_hdr()

commit 8da32de5c845b711a500f89342baf10c662e2ecb
Author: Kumar Gala <galak@kernel.crashing.org>
Date:   Fri Jun 29 00:12:04 2007 -0500

    gianfar: Fix typo bug introduced by move to udp_hdr()

    In commit 4bedb45203eab92a87b4c863fe2d0cded633427f both the udp and tcp
    cases where changed to use udp_hdr() instead of leaving the tcp case
    alone and fixing with tcp_hdr().

    This ended up causing random behavior with TCP connections because
    of looking for tcp_hdr()->check in the wrong place.

    Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6822bf1..1b854bf 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -944,7 +944,7 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb)
 		flags |= TXFCB_UDP;
 		fcb->phcs = udp_hdr(skb)->check;
 	} else
-		fcb->phcs = udp_hdr(skb)->check;
+		fcb->phcs = tcp_hdr(skb)->check;

 	/* l3os is the distance between the start of the
 	 * frame (skb->data) and the start of the IP hdr.
