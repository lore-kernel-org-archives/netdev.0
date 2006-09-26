From: mostrows@earthlink.net
Subject: Subject: [PATCH] Advertise PPPoE MTU (resubmit).
Date: Tue, 26 Sep 2006 06:31:38 -0500
Message-ID: <11592702983561-git-send-email-mostrows@earthlink.net>
Reply-To: mostrows@earthlink.net
Cc: Michal Ostrowski <mostrows@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:60863 "EHLO
	igw2.watson.ibm.com") by vger.kernel.org with ESMTP
	id S1750854AbWIZLag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 07:30:36 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ppp-bugs@dp.samba.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PPPoE must advertise the underlying device's MTU via the ppp channel
descriptor structure, as multilink functionality depends on it.

Signed-off-by: Michal Ostrowski <mostrows@earthlink.net>
---
 drivers/net/pppoe.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 475dc93..c89e9ee 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -600,6 +600,7 @@ static int pppoe_connect(struct socket *
 		po->chan.hdrlen = (sizeof(struct pppoe_hdr) +
 				   dev->hard_header_len);
 
+		po->chan.mtu = dev->mtu - sizeof(struct pppoe_hdr);
 		po->chan.private = sk;
 		po->chan.ops = &pppoe_chan_ops;
 
-- 
1.4.1.1

