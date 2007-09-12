From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/16] net: Disable netfilter sockopts when not in the
 initial network namespace
Date: Wed, 12 Sep 2007 05:03:11 -0700 (PDT)
Message-ID: <20070912.050311.78725619.davem@davemloft.net>
References: <m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps0su8wv.fsf_-_@ebiederm.dsl.xmission.com>
	<20070912.045903.104046208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:56545
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765561AbXILMDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:03:43 -0400
In-Reply-To: <20070912.045903.104046208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I added the following patch to net-2.6.24 to kill a warning
since net_alloc() has no users (yet).

commit f444fa9b5d70b3d431e1554e0975e012514c39f3
Author: David S. Miller <davem@kimchee.(none)>
Date:   Wed Sep 12 14:01:08 2007 +0200

    [NET]: #if 0 out net_alloc() for now.
    
    We will undo this once it is actually used.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index f259a9b..1fc513c 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -32,10 +32,12 @@ void net_unlock(void)
 	mutex_unlock(&net_list_mutex);
 }
 
+#if 0
 static struct net *net_alloc(void)
 {
 	return kmem_cache_alloc(net_cachep, GFP_KERNEL);
 }
+#endif
 
 static void net_free(struct net *net)
 {
