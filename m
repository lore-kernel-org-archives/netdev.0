From: Michal Ludvig <michal@logix.cz>
Subject: [PATCH] sha2-256 truncation
Date: Fri, 09 Jan 2004 09:50:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FFE6B72.9030808@logix.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090003070806070002080905"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090003070806070002080905
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,
the attached trivial patch corrects the truncation size of computed 
hashes that are used in IPsec ESP/AH packets for SHA2-256. All other 
hash algorithms use 96 bits as well as does SuperFreeS/WAN and FreeBSD 
also for SHA2-256. Only the native Linux sha2-256 used 128 bits what led 
  to incompatibility with other IPsec implementations.

Please apply, thanks!

Michal Ludvig
-- 
* A mouse is a device used to point at the xterm you want to type in.
* Personal homepage - http://www.logix.cz/michal

--------------090003070806070002080905
Content-Type: text/plain;
 name="kernel-sha256.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel-sha256.diff"

--- linux-2.6.0/net/xfrm/xfrm_algo.c	2004-01-08 01:29:52.067261651 +0100
+++ linux-2.6.0.orig/net/xfrm/xfrm_algo.c	2004-01-08 01:28:38.668690081 +0100
@@ -85,7 +85,7 @@ static struct xfrm_algo_desc aalg_list[]
 
 	.uinfo = {
 		.auth = {
-			.icv_truncbits = 96,
+			.icv_truncbits = 128,
 			.icv_fullbits = 256,
 		}
 	},

--------------090003070806070002080905--
