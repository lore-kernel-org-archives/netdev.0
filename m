From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 3 Aug 2017 12:01:37 +1000
Message-ID: <20170803120137.697ebace@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/hyperv/netvsc.c

between commit:

  4a0dee1ffe0e ("netvsc: Initialize 64-bit stats seqcount")

from the net tree and commit:

  35fbbccfb417 ("netvsc: save pointer to parent netvsc_device in channel table")

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

diff --cc drivers/net/hyperv/netvsc.c
index 96f90c75d1b7,9598220b3bcc..000000000000
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@@ -1302,8 -1269,7 +1269,9 @@@ struct netvsc_device *netvsc_device_add
  		struct netvsc_channel *nvchan = &net_device->chan_table[i];
  
  		nvchan->channel = device->channel;
+ 		nvchan->net_device = net_device;
 +		u64_stats_init(&nvchan->tx_stats.syncp);
 +		u64_stats_init(&nvchan->rx_stats.syncp);
  	}
  
  	/* Enable NAPI handler before init callbacks */
