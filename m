From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the netfilter
 tree
Date: Thu, 10 Nov 2016 10:56:33 +1100
Message-ID: <20161110105633.31ebdc76@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        NetFilter <netfilter-devel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/netfilter/ipvs/ip_vs_ctl.c

between commit:

  8fbfef7f505b ("ipvs: use IPVS_CMD_ATTR_MAX for family.maxattr")

from the netfilter tree and commit:

  489111e5c25b ("genetlink: statically initialize families")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/netfilter/ipvs/ip_vs_ctl.c
index a6e44ef2ec9a,6b85ded4f91d..000000000000
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@@ -3872,10 -3865,20 +3865,20 @@@ static const struct genl_ops ip_vs_genl
  	},
  };
  
+ static struct genl_family ip_vs_genl_family __ro_after_init = {
+ 	.hdrsize	= 0,
+ 	.name		= IPVS_GENL_NAME,
+ 	.version	= IPVS_GENL_VERSION,
 -	.maxattr	= IPVS_CMD_MAX,
++	.maxattr	= IPVS_CMD_ATTR_MAX,
+ 	.netnsok        = true,         /* Make ipvsadm to work on netns */
+ 	.module		= THIS_MODULE,
+ 	.ops		= ip_vs_genl_ops,
+ 	.n_ops		= ARRAY_SIZE(ip_vs_genl_ops),
+ };
+ 
  static int __init ip_vs_genl_register(void)
  {
- 	return genl_register_family_with_ops(&ip_vs_genl_family,
- 					     ip_vs_genl_ops);
+ 	return genl_register_family(&ip_vs_genl_family);
  }
  
  static void ip_vs_genl_unregister(void)
