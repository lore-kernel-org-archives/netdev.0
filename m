From: Eric Brower <ebrower@usa.net>
Subject: [PATCH] sk98lin hardware rx csum offload logic
Date: Wed, 16 Feb 2005 11:38:24 -0800
Message-ID: <4213A130.8070909@usa.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020406010901000006040902"
To: netdev@oss.sgi.com, linux@syskonnect.de
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020406010901000006040902
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The sk98lin driver drops received packets that have an invalid 
IP/UDP/TCP checksum-- it should be passing these packets up the stack by 
marking the skb's ip_summed to CHECKSUM_NONE rather than simply dropping 
them (ref. 
http://efault.net/npat/docs_and_postings/net_device-features/net_device-features.txt 
and other network driver implementations)

Attached is a patch against the latest BK 2.6 kernel.  This issue also 
applies to 2.4 and the latest version of the driver (8.13.1.3) on the 
SysKonnect site, though in that case a similar fix needs to be made to 
the sky2.c Yukon2 support.

I'm not on the netdev list, so if there is any further discussion please 
include me directly.

Thanks,
E

--------------020406010901000006040902
Content-Type: text/plain;
 name="sk98lin_hwrxcsum.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sk98lin_hwrxcsum.patch"

===== drivers/net/sk98lin/skge.c 1.54 vs edited =====
--- 1.54/drivers/net/sk98lin/skge.c	2004-11-03 14:31:05 -08:00
+++ edited/drivers/net/sk98lin/skge.c	2005-02-16 09:14:02 -08:00
@@ -2254,8 +2254,8 @@
 							/* HW Checksum error */
 							SK_DBG_MSG(NULL, SK_DBGMOD_DRV,
 							SK_DBGCAT_DRV_RX_PROGRESS,
-							("skge: CRC error. Frame dropped!\n"));
-							goto rx_failed;
+							("skge: CRC error.\n"));
+							pMsg->ip_summed = CHECKSUM_NONE;
 						} else {
 								pMsg->ip_summed =
 								CHECKSUM_NONE;

--------------020406010901000006040902--
