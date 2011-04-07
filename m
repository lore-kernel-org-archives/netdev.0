From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Thu, 7 Apr 2011 11:39:43 +1000
Message-ID: <20110407113943.2f054e2f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sathya Perla <sathya.perla@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/benet/be_main.c between commit 2d5d41546504 ("be2net: Fix a
potential crash during shutdown.") from the net-current tree and commit
0f4a68288217 ("be2net: cancel be_worker in be_shutdown() even when i/f is
down") from the net tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/benet/be_main.c
index 88d4c80,a24fb45..0000000
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@@ -3142,14 -3152,11 +3153,13 @@@ static int be_resume(struct pci_dev *pd
  static void be_shutdown(struct pci_dev *pdev)
  {
  	struct be_adapter *adapter = pci_get_drvdata(pdev);
 -	struct net_device *netdev =  adapter->netdev;
 +
 +	if (!adapter)
 +		return;
  
- 	if (netif_running(adapter->netdev))
- 		cancel_delayed_work_sync(&adapter->work);
+ 	cancel_delayed_work_sync(&adapter->work);
  
 -	netif_device_detach(netdev);
 +	netif_device_detach(adapter->netdev);
  
  	be_cmd_reset_function(adapter);
  
