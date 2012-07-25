From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] igb: correct hardware type (i210/i211) check in
 igb_loopback_test()
Date: Wed, 25 Jul 2012 21:05:39 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1207252059320.11754@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Jeff Pieper <jeffrey.e.pieper@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the original code
...
 	if ((adapter->hw.mac.type == e1000_i210)
		|| (adapter->hw.mac.type == e1000_i210)) {
...
the second check of 'adapter->hw.mac.type' is pointless since it tests
for the exact same value as the first.

After reading through a few other parts of the driver I believe that
the second check was actually intended to check for 'e1000_i211'
rather than 'e1000_i210', but I admit that I'm not certain so someone
with more knowledge about this driver should ACK the patch before it
gets merged.

Unfortunately I have no hardware to actually test this on, so it is
compile tested only.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index a19c84c..ad489b7 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1783,7 +1783,7 @@ static int igb_loopback_test(struct igb_adapter *adapter, u64 *data)
 		goto out;
 	}
 	if ((adapter->hw.mac.type == e1000_i210)
-		|| (adapter->hw.mac.type == e1000_i210)) {
+		|| (adapter->hw.mac.type == e1000_i211)) {
 		dev_err(&adapter->pdev->dev,
 			"Loopback test not supported "
 			"on this part at this time.\n");
-- 
1.7.11.3


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
