From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 6 Jun 2017 11:49:41 +1000
Message-ID: <20170606114941.20a80fb0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/dsa/dsa2.c

between commit:

  b07ac9894644 ("net: dsa: Fix stale cpu_switch reference after unbind then bind")

from the net tree and commits:

  8b0d3ea55587 ("net: dsa: store CPU port pointer in the tree")
  937c7df85ce7 ("net: dsa: Pass dsa_port reference to ethtool setup/restore")

from the net-next tree.

I fixed it up (I think (maybe it should be "dst->cpu_dp.ds = NULL"?) -
see below) and can carry the fix as necessary. This is now fixed as far
as linux-next is concerned, but any non trivial conflicts should be
mentioned to your upstream maintainer when your tree is submitted for
merging.  You may also want to consider cooperating with the maintainer
of the conflicting tree to minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/dsa/dsa2.c
index 7796580e99ee,cd13bb54a30c..000000000000
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@@ -484,10 -474,8 +474,10 @@@ static void dsa_dst_unapply(struct dsa_
  		dsa_ds_unapply(dst, ds);
  	}
  
- 	if (dst->cpu_switch) {
- 		dsa_cpu_port_ethtool_restore(dst->cpu_switch);
- 		dst->cpu_switch = NULL;
 -	if (dst->cpu_dp)
++	if (dst->cpu_dp) {
+ 		dsa_cpu_port_ethtool_restore(dst->cpu_dp);
++		dst->cpu_dp = NULL;
 +	}
  
  	pr_info("DSA: tree %d unapplied\n", dst->tree);
  	dst->applied = false;
