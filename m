From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Wed, 12 May 2010 12:26:19 +1000
Message-ID: <20100512122619.be64cea0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andreas Meissner <andreas.meissner@sphairon.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/ipv4/ipmr.c between commit bbd725435ddb1cac732f7a8c23c21ff67f24c60f
("IPv4: unresolved multicast route cleanup") from Linus' tree and commits
e258beb22f4d3ea3dc88586ffc9c990d0eb03380 ("ipv4: ipmr: move unres_queue
and timer to per-namespace data") and
0c12295a741d3186987f96f518cfbdaf01abb087 ("ipv4: ipmr: move mroute data
into seperate structure") from the net tree.

I fixed it up (see below) and can carry the fix for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/ipmr.c
index ec19a89,f3f1c6b..0000000
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@@ -750,12 -995,10 +995,11 @@@ ipmr_cache_unresolved(struct mr_table *
  			return err;
  		}
  
- 		atomic_inc(&net->ipv4.cache_resolve_queue_len);
- 		c->next = mfc_unres_queue;
- 		mfc_unres_queue = c;
+ 		atomic_inc(&mrt->cache_resolve_queue_len);
+ 		list_add(&c->list, &mrt->mfc_unres_queue);
  
 -		mod_timer(&mrt->ipmr_expire_timer, c->mfc_un.unres.expires);
 +		if (atomic_read(&net->ipv4.cache_resolve_queue_len) == 1)
- 			mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
++			mod_timer(&mrt->ipmr_expire_timer, c->mfc_un.unres.expires);
  	}
  
  	/*
