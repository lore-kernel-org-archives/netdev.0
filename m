From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the wireless-current
 tree
Date: Tue, 29 Dec 2009 09:54:32 +1100
Message-ID: <20091229095432.f39a887e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Samuel Ortiz <sameo@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Holger Schurig <holgerschurig@googlemail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752309AbZL1Wyi@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/wireless/libertas/scan.c between commit
659c8e5243caf14564155ad8421404f044dd8031 ("libertas: Remove carrier
signaling from the scan code") from the wireless-current tree and commit
602114ae595af6c89eab149cf9f939e3f7ef4a34 ("libertas: add access functions
for mesh open/connect status") from the net tree.

I fixed it up (see below) and can carry the fix for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/libertas/scan.c
index b0b1c78,4a0c3e3..0000000
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@@ -632,13 -635,16 +632,13 @@@ out2
  	priv->scan_channel = 0;
  
  out:
 -	if (priv->connect_status == LBS_CONNECTED) {
 -		netif_carrier_on(priv->dev);
 -		if (!priv->tx_pending_len)
 -			netif_wake_queue(priv->dev);
 -	}
 -	if (priv->mesh_dev && lbs_mesh_connected(priv)) {
 -		netif_carrier_on(priv->mesh_dev);
 -		if (!priv->tx_pending_len)
 -			netif_wake_queue(priv->mesh_dev);
 -	}
 +	if (priv->connect_status == LBS_CONNECTED && !priv->tx_pending_len)
 +		netif_wake_queue(priv->dev);
 +
- 	if (priv->mesh_dev && (priv->mesh_connect_status == LBS_CONNECTED) &&
++	if (priv->mesh_dev && lbs_mesh_connected(priv) &&
 +	    !priv->tx_pending_len)
 +		netif_wake_queue(priv->mesh_dev);
 +
  	kfree(chan_list);
  
  	lbs_deb_leave_args(LBS_DEB_SCAN, "ret %d", ret);
