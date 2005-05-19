From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Thu, 19 May 2005 13:33:33 -0700
Message-ID: <20050519133333.07a992e6@dxpl.pdx.osdl.net>
References: <20050518235329.GA17946@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <20050518235329.GA17946@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a somewhat different patch from 2.6.12-rc4-bridge
http://developer.osdl.org/shemminger/patches/2.6.12-rc4-bridge/

The bridge doesn't need locking, or checksumming and can allow highdma
buffers; all of which are handled by net/core/dev.c if needed.


===================================================================
--- netem-2.6.12-rc4.orig/net/bridge/br_device.c
+++ netem-2.6.12-rc4/net/bridge/br_device.c
@@ -101,4 +99,6 @@ void br_dev_setup(struct net_device *dev
 	dev->tx_queue_len = 0;
 	dev->set_mac_address = NULL;
 	dev->priv_flags = IFF_EBRIDGE;
+	dev->features |= NETIF_F_SG | NETIF_F_NO_CSUM 
+		| NETIF_F_HIGHDMA | NETIF_F_LLTX;
 }
