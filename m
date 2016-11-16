From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 17 Nov 2016 10:36:28 +1100
Message-ID: <20161117103628.4cf3e73b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jarod Wilson <jarod@redhat.com>,
        Sunil Goutham <sgoutham@cavium.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/cavium/thunder/nicvf_main.c

between commit:

  712c31853440 ("net: thunderx: Program LMAC credits based on MTU")

from the net tree and commit:

  109cc16526c6 ("ethernet/cavium: use core min/max MTU checking")

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

diff --cc drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 8a37012c9c89,b192712c93b7..000000000000
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@@ -1292,19 -1312,10 +1292,13 @@@ static int nicvf_change_mtu(struct net_
  {
  	struct nicvf *nic = netdev_priv(netdev);
  
- 	if (new_mtu > NIC_HW_MAX_FRS)
- 		return -EINVAL;
- 
- 	if (new_mtu < NIC_HW_MIN_FRS)
- 		return -EINVAL;
- 
 +	netdev->mtu = new_mtu;
 +
 +	if (!netif_running(netdev))
 +		return 0;
 +
  	if (nicvf_update_hw_max_frs(nic, new_mtu))
  		return -EINVAL;
 -	netdev->mtu = new_mtu;
 -	nic->mtu = new_mtu;
  
  	return 0;
  }
