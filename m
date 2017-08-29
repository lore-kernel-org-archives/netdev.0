From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 29 Aug 2017 12:25:59 +1000
Message-ID: <20170829122559.6032454a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/marvell/mvpp2.c

between commit:

  4c2286826451 ("net: mvpp2: fix the mac address used when using PPv2.2")

from the net tree and commits:

  09f8397553a2 ("net: mvpp2: introduce per-port nrxqs/ntxqs variables")
  213f428f5056 ("net: mvpp2: add support for TX interrupts and RX queue distribution modes")

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

diff --cc drivers/net/ethernet/marvell/mvpp2.c
index 4d598ca8503a,fea9ae5b70ba..000000000000
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@@ -6504,7 -7248,9 +7248,9 @@@ static int mvpp2_port_probe(struct plat
  	struct resource *res;
  	const char *dt_mac_addr;
  	const char *mac_from;
 -	char hw_mac_addr[ETH_ALEN];
 +	char hw_mac_addr[ETH_ALEN] = {0};
+ 	unsigned int ntxqs, nrxqs;
+ 	bool has_tx_irqs;
  	u32 id;
  	int features;
  	int phy_mode;
