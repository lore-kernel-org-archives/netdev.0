From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] some condition check error in ipsec v6
Date: Wed, 9 Jun 2004 16:29:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406091629.17365.mashirle@us.ibm.com>
References: <OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com> <200403311326.43647.mashirle@us.ibm.com> <200405261308.54281.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_N15xAnTdM2U6Z4o"
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <200405261308.54281.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_N15xAnTdM2U6Z4o
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Here is a small patch for condition checking in ah6.c and esp6.c. This patch 
is against 2.6.6 kernel.

-- 
Thanks
Shirley Ma
IBM Linux Technology Center


--Boundary-00=_N15xAnTdM2U6Z4o
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="linux-2.6.6-ipsec.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.6-ipsec.patch"

diff -urN linux-2.6.6/net/ipv6/ah6.c linux-2.6.6-ipsec/net/ipv6/ah6.c
--- linux-2.6.6/net/ipv6/ah6.c	2004-05-09 19:32:53.000000000 -0700
+++ linux-2.6.6-ipsec/net/ipv6/ah6.c	2004-06-09 16:13:26.000000000 -0700
@@ -360,7 +360,7 @@
 	struct ip_auth_hdr *ah = (struct ip_auth_hdr*)(skb->data+offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH ||
+	if (type != ICMPV6_DEST_UNREACH &&
 	    type != ICMPV6_PKT_TOOBIG)
 		return;
 
diff -urN linux-2.6.6/net/ipv6/esp6.c linux-2.6.6-ipsec/net/ipv6/esp6.c
--- linux-2.6.6/net/ipv6/esp6.c	2004-05-09 19:32:52.000000000 -0700
+++ linux-2.6.6-ipsec/net/ipv6/esp6.c	2004-06-09 16:13:38.000000000 -0700
@@ -324,7 +324,7 @@
 	struct ipv6_esp_hdr *esph = (struct ipv6_esp_hdr*)(skb->data+offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH ||
+	if (type != ICMPV6_DEST_UNREACH && 
 	    type != ICMPV6_PKT_TOOBIG)
 		return;
 

--Boundary-00=_N15xAnTdM2U6Z4o--
