From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/2] IPV6: use ipv6_addr_any()
Date: Wed, 28 Jan 2004 16:30:43 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128.163043.120256112.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Use simple ipv6_addr_any()
where ipv6_addr_type() is called only to check for unspecified address.

Thanks.

===== net/ipv6/af_inet6.c 1.60 vs edited =====
--- 1.60/net/ipv6/af_inet6.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/af_inet6.c	Wed Jan 28 16:11:31 2004
@@ -464,7 +464,7 @@
 		if (np->sndflow)
 			sin->sin6_flowinfo = np->flow_label;
 	} else {
-		if (ipv6_addr_type(&np->rcv_saddr) == IPV6_ADDR_ANY)
+		if (ipv6_addr_any(&np->rcv_saddr))
 			ipv6_addr_copy(&sin->sin6_addr, &np->saddr);
 		else
 			ipv6_addr_copy(&sin->sin6_addr, &np->rcv_saddr);
===== net/ipv6/ndisc.c 1.64 vs edited =====
--- 1.64/net/ipv6/ndisc.c	Thu Jan 22 15:38:40 2004
+++ edited/net/ipv6/ndisc.c	Wed Jan 28 16:13:21 2004
@@ -544,7 +544,7 @@
 	}
 
 	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
-	send_llinfo = dev->addr_len && ipv6_addr_type(saddr) != IPV6_ADDR_ANY;
+	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
 	if (send_llinfo)
 		len += NDISC_OPT_SPACE(dev->addr_len);
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
