From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: [PATCH] IPV6: fix checking for reserved subnet anycast
Date: Tue, 03 Feb 2004 02:07:41 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203.020741.105137354.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@wide.ad.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Reserved subnet anycast is as follows:
   11111101 11....11 1xxxxxxx
The code checking for reserved subnet anycast in 
__ipv6_regen_rndid() was incorrect.

D: fix checking for reserved subnet anycast in __ipv6_regen_rndid().

===== net/ipv6/addrconf.c 1.90 vs edited =====
--- 1.90/net/ipv6/addrconf.c	Sun Jan 25 03:09:52 2004
+++ edited/net/ipv6/addrconf.c	Tue Feb  3 01:39:19 2004
@@ -1147,7 +1147,7 @@
 	 *  - XXX: already assigned to an address on the device
 	 */
 	if (idev->rndid[0] == 0xfd && 
-	    (idev->rndid[1]&idev->rndid[2]&idev->rndid[3]&idev->rndid[4]&idev->rndid[5]&idev->rndid[6]) &&
+	    (idev->rndid[1]&idev->rndid[2]&idev->rndid[3]&idev->rndid[4]&idev->rndid[5]&idev->rndid[6]) == 0xff &&
 	    (idev->rndid[7]&0x80))
 		goto regen;
 	if ((idev->rndid[0]|idev->rndid[1]) == 0) {

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
