From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix build without CONFIG_NET_NS
Date: Mon, 23 Feb 2009 18:39:35 -0800 (PST)
Message-ID: <20090223.183935.201291589.davem@davemloft.net>
References: <20090224022734.1766BDDE1D@ozlabs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
To: benh@kernel.crashing.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756783AbZBXCkB@vger.kernel.org>
In-Reply-To: <20090224022734.1766BDDE1D@ozlabs.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 24 Feb 2009 13:26:45 +1100

> Commit 486a87f1e5624096bd1c09e9e716239597d48dca broke build without
> CONFIG_NET_NS due to calling net_alloc_generic() always while defining
> it inside an #ifdef CONFIG_NET_NS block. This moves the function
> definition out of that block.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Yep, sorry about that.

commit ebe47d47b7b7fed72dabcce4717da727b4e2367d
Author: Clemens Noss <cnoss@gmx.de>
Date:   Mon Feb 23 15:37:35 2009 -0800

    netns: build fix for net_alloc_generic
    
    net_alloc_generic was defined in #ifdef CONFIG_NET_NS, but used
    unconditionally. Move net_alloc_generic out of #ifdef.
    
    Signed-off-by: Clemens Noss <cnoss@gmx.de>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index b0767ab..2adb1a7 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -63,10 +63,6 @@ out_undo:
 	goto out;
 }
 
-#ifdef CONFIG_NET_NS
-static struct kmem_cache *net_cachep;
-static struct workqueue_struct *netns_wq;
-
 static struct net_generic *net_alloc_generic(void)
 {
 	struct net_generic *ng;
@@ -80,6 +76,10 @@ static struct net_generic *net_alloc_generic(void)
 	return ng;
 }
 
+#ifdef CONFIG_NET_NS
+static struct kmem_cache *net_cachep;
+static struct workqueue_struct *netns_wq;
+
 static struct net *net_alloc(void)
 {
 	struct net *net = NULL;
