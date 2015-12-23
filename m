From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 07/28] net: dsa: Remove allocation of driver private memory
Date: Wed, 23 Dec 2015 13:56:21 +0100
Message-ID: <1450875402-20740-8-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48714 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757135AbbLWM5s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:48 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The drivers now allocate their own memory for private usage. Remove
the allocation from the core code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
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
index 7170c93637c8..ee6177c602fb 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -400,7 +400,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	/*
 	 * Allocate and initialise switch state.
 	 */
-	ds = devm_kzalloc(parent, sizeof(*ds) + drv->priv_size, GFP_KERNEL);
+	ds = devm_kzalloc(parent, sizeof(*ds), GFP_KERNEL);
 	if (ds == NULL)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.6.3
