From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] bna: off by one
Date: Sun, 19 Sep 2010 01:41:44 +0200
Message-ID: <20100918234144.GB6236@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Debashis Dutt <ddutt@brocade.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:64667 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204Ab0IRXmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Sep 2010 19:42:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mod->mbhdlr[] array has BFI_MC_MAX elements.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index caa45c2..73493de 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1514,7 +1514,7 @@ bfa_nw_ioc_mbox_isr(struct bfa_ioc *ioc)
 		return;
 	}
 
-	if ((mc > BFI_MC_MAX) || (mod->mbhdlr[mc].cbfn == NULL))
+	if ((mc >= BFI_MC_MAX) || (mod->mbhdlr[mc].cbfn == NULL))
 		return;
 
 	mod->mbhdlr[mc].cbfn(mod->mbhdlr[mc].cbarg, &m);
