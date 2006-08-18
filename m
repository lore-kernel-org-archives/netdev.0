From: Vasily Averin <vvs@sw.ru>
Subject: [PATCH] e1000: ring buffers resources cleanup
Date: Fri, 18 Aug 2006 19:02:34 +0400
Message-ID: <44E5D68A.2080804@sw.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060505050108000504020602"
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
To: netdev@vger.kernel.org, Jeb Cramer <cramerj@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>, Andrew Morton <akpm@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, devel@openvz.org,
	e1000-devel@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060505050108000504020602
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Memory leak was found in 2.6.18-rc4 and e1000 7.2.7 from sourceforge:
We should free resources allocated for previous rings if following allocation fails.

Signed-off-by: Vasily Averin <vvs@sw.ru>

Thank you,
	Vasily Averin
SWsoft Virtuozzo/OpenVZ Linux kernel team


--------------060505050108000504020602
Content-Type: text/plain;
 name="diff-e1000-ringresources-20060818"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff-e1000-ringresources-20060818"

--- linux-2.6.18-rc4/drivers/net/e1000/e1000_main.c.irsrs	2006-08-18 16:58:51.000000000 +0400
+++ linux-2.6.18-rc4/drivers/net/e1000/e1000_main.c	2006-08-18 18:53:05.000000000 +0400
@@ -1398,6 +1398,9 @@ e1000_setup_all_tx_resources(struct e100
 		if (err) {
 			DPRINTK(PROBE, ERR,
 				"Allocation for Tx Queue %u failed\n", i);
+			for (i-- ; i >= 0; i--)
+				e1000_free_tx_resources(adapter,
+							&adapter->tx_ring[i]);
 			break;
 		}
 	}
@@ -1656,6 +1659,9 @@ e1000_setup_all_rx_resources(struct e100
 		if (err) {
 			DPRINTK(PROBE, ERR,
 				"Allocation for Rx Queue %u failed\n", i);
+			for (i-- ; i >= 0; i--)
+				e1000_free_rx_resources(adapter,
+							&adapter->rx_ring[i]);
 			break;
 		}
 	}

--------------060505050108000504020602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------060505050108000504020602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--------------060505050108000504020602--
