From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/7] net: dsa: Remove allocation of driver private memory
Date: Mon, 11 Apr 2016 21:50:05 +0200
Message-ID: <1460404209-32083-4-git-send-email-andrew@lunn.ch>
References: <1460404209-32083-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53443 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbcDKTwf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 15:52:35 -0400
In-Reply-To: <1460404209-32083-1-git-send-email-andrew@lunn.ch>
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
index 7bc7bd9b5ded..165c2e10615c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -213,7 +213,6 @@ struct dsa_switch_driver {
 	struct list_head	list;
 
 	enum dsa_tag_protocol	tag_protocol;
-	int			priv_size;
 
 	/*
 	 * Probing and setup.
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 7ef8a92a9e39..14bf12f637d2 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -402,7 +402,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	/*
 	 * Allocate and initialise switch state.
 	 */
-	ds = devm_kzalloc(parent, sizeof(*ds) + drv->priv_size, GFP_KERNEL);
+	ds = devm_kzalloc(parent, sizeof(*ds), GFP_KERNEL);
 	if (ds == NULL)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.7.0
