From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: fix payload length of reassembled packet
Date: Thu, 12 Jun 2003 02:07:16 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.020716.37975763.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I've introduced a bug, which calculates payload length
incorrectly when reassembling.
Bug was introduced in ChangeSet 1.1229.7.40.
(This patch also eliminates redundancy.)

Thanks in advance.

Index: linux-2.5/net/ipv6/reassembly.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/reassembly.c,v
retrieving revision 1.15
diff -u -r1.15 reassembly.c
--- linux-2.5/net/ipv6/reassembly.c	30 May 2003 17:46:04 -0000	1.15
+++ linux-2.5/net/ipv6/reassembly.c	11 Jun 2003 15:49:44 -0000
@@ -596,10 +596,8 @@
 	BUG_TRAP(FRAG6_CB(head)->offset == 0);
 
 	/* Unfragmented part is taken from the first segment. */
-	payload_len = (head->data - head->nh.raw) - sizeof(struct ipv6hdr) + fq->len;
-	nhoff = head->h.raw - head->nh.raw;
-
-	if (payload_len > 65535 + 8)
+	payload_len = (head->data - head->nh.raw) - sizeof(struct ipv6hdr) + fq->len - 8;
+	if (payload_len > 65535)
 		goto out_oversize;
 
 	/* Head of list must not be cloned. */

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
