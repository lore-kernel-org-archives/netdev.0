From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: Re: [PATCH] igb: correct hardware type (i210/i211)
 check in igb_loopback_test()
Date: Wed, 25 Jul 2012 19:13:36 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B62630D64753@ORSMSX102.amr.corp.intel.com>
References: <alpine.LNX.2.00.1207252059320.11754@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Rick Jones <rick.jones2@hp.com>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "David S. Miller" <davem@davemloft.net>
To: Jesper Juhl <jj@chaosbits.net>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LNX.2.00.1207252059320.11754@swampdragon.chaosbits.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



-----Original Message-----
From: Jesper Juhl [mailto:jj@chaosbits.net] 
Sent: Wednesday, July 25, 2012 12:06 PM
To: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Wyborny, Carolyn; Pieper, Jeffrey E; Kirsher, Jeffrey T; Rick Jones; Ronciak, John; Brandeburg, Jesse; Allan, Bruce W; Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P; Duyck, Alexander H; David S. Miller
Subject: [PATCH] igb: correct hardware type (i210/i211) check in igb_loopback_test()

In the original code
...
 	if ((adapter->hw.mac.type == e1000_i210)
		|| (adapter->hw.mac.type == e1000_i210)) { ...
the second check of 'adapter->hw.mac.type' is pointless since it tests for the exact same value as the first.

After reading through a few other parts of the driver I believe that the second check was actually intended to check for 'e1000_i211'
rather than 'e1000_i210', but I admit that I'm not certain so someone with more knowledge about this driver should ACK the patch before it gets merged.

Unfortunately I have no hardware to actually test this on, so it is compile tested only.

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

ACK.

Good catch.  Thanks Jesper!

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation




------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
