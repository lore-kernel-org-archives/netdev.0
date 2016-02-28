From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 06/32] net: dsa: Remove allocation of driver private memory
Date: Sun, 28 Feb 2016 17:41:14 +0100
Message-ID: <1456677700-23027-7-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44983 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759861AbcB1QnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:43:08 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The drivers now allocate their own memory for private usage. Remove
the allocation from the core code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 1 -
 net/dsa/dsa.c     | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 05067b030962..f6b8001a500f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -213,7 +213,6 @@ struct dsa_switch_driver {
 	struct list_head	list;
 
 	enum dsa_tag_protocol	tag_protocol;
-	int			priv_size;
 
 	/*
 	 * Probing and setup.
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d6ea1f1a1a34..6c9d1d812873 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -444,7 +444,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	/*
 	 * Allocate and initialise switch state.
 	 */
-	ds = devm_kzalloc(parent, sizeof(*ds) + drv->priv_size, GFP_KERNEL);
+	ds = devm_kzalloc(parent, sizeof(*ds), GFP_KERNEL);
 	if (ds == NULL)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.7.0
