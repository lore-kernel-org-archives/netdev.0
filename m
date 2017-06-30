From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Fri, 30 Jun 2017 10:57:51 +1000
Message-ID: <20170630105751.543eb510@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:45417 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751666AbdF3A5y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 20:57:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/rocker/rocker_ofdpa.c

between commit:

  acb4b7df48b5 ("rocker: move dereference before free")

from Linus' tree and commit:

  00fc0c51e35b ("rocker: Change world_ops API and implementation to be switchdev independant")

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

diff --cc drivers/net/ethernet/rocker/rocker_ofdpa.c
index a9ce82d3e9cf,bd0e3f157e9e..000000000000
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@@ -1505,10 -1409,10 +1409,10 @@@ static int ofdpa_port_ipv4_nh(struct of
  		*index = entry->index;
  		resolved = false;
  	} else if (removing) {
 -		ofdpa_neigh_del(found);
  		*index = found->index;
- 		ofdpa_neigh_del(trans, found);
++		ofdpa_neigh_del(found);
  	} else if (updating) {
- 		ofdpa_neigh_update(found, trans, NULL, false);
+ 		ofdpa_neigh_update(found, NULL, false);
  		resolved = !is_zero_ether_addr(found->eth_dst);
  		*index = found->index;
  	} else {
