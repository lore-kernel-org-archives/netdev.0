From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 21 Oct 2016 10:40:46 +1100
Message-ID: <20161021104046.2bfb8b58@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jarod Wilson <jarod@redhat.com>,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/ibm/ibmvnic.c

between commit:

  87737f8810db ("ibmvnic: Update MTU after device initialization")

from the net tree and commit:

  d894be57ca92 ("ethernet: use net core MTU range checking in more drivers")

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

diff --cc drivers/net/ethernet/ibm/ibmvnic.c
index 213162df1a9b,657206be7ba9..000000000000
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@@ -3654,7 -3644,8 +3644,9 @@@ static void handle_crq_init_rsp(struct 
  		goto task_failed;
  
  	netdev->real_num_tx_queues = adapter->req_tx_queues;
 +	netdev->mtu = adapter->req_mtu;
+ 	netdev->min_mtu = adapter->min_mtu;
+ 	netdev->max_mtu = adapter->max_mtu;
  
  	if (adapter->failover) {
  		adapter->failover = false;
