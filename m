From: Florian Zumbiehl <florz@florz.de>
Subject: [PATCH] skge: restore multicast rx filter on resume
Date: Sun, 25 Dec 2011 09:18:33 +0100
Message-ID: <20111225081833.GC3088@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rain.florz.de ([62.216.164.86]:59529 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751376Ab1LYJCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Dec 2011 04:02:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

no clue whether this is really the correct[tm] way to fix this, but it
makes it so that IPv6 doesn't start failing after a suspend/resume cycle
because neighbour discovery stops working ...

Florian

---------------------------------------------------------------------------
skge: restore multicast rx filter on resume
    
Signed-off-by: Florian Zumbiehl <florz@florz.de>

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index f4be5c7..cd968e5 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -4046,6 +4046,7 @@ static int skge_resume(struct device *dev)
 				dev_close(dev);
 				goto out;
 			}
+			skge_set_multicast(dev);
 		}
 	}
 out:
