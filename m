From: Sebastian =?iso-8859-1?Q?P=F6hn?= <s.poehn@stud.hs-esslingen.de>
Subject: [PATCH] ethtool: mask out FLOW_EXT
Date: Mon, 23 May 2011 15:53:55 +0200 (CEST)
Message-ID: <31603.80.254.147.148.1306158835.squirrel@webmail.hs-esslingen.de>
Reply-To: s.poehn@stud.hs-esslingen.de
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: sebastian.poehn@belden.com, bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.hs-esslingen.de ([134.108.32.78]:46193 "EHLO
	mail.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755382Ab1EWNx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 09:53:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the disclaimer the last time!

The FLOW_EXT bit must be masked out. Otherwise if e.g. vlan is set a
driver receiving the ntuple may not detect the flow_type correctly!

Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---

diff --git a/ethtool.c b/ethtool.c
index 34fe107..0b7ec05 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3134,6 +3134,9 @@ static int flow_spec_to_ntuple(struct
ethtool_rx_flow_spec *fsp,
                 (u64)ntohl(~fsp->m_ext.data[1]);
         }
     }
+
+    /*Mask out the extended bit, because ntuple does not know it!*/
+    ntuple->flow_type &= ~FLOW_EXT;

     return 0;
 }
