From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 4/4] [IPV4]: Just increment OutDatagrams once per a
 datagram.
Date: Thu, 13 Sep 2007 09:31:06 +0900 (JST)
Message-ID: <20070913.093106.30240091.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44035 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106AbXIMA3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 20:29:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index facb7e2..ccb67f3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -504,6 +504,8 @@ send:
 out:
 	up->len = 0;
 	up->pending = 0;
+	if (!err)
+		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, up->pcflag);
 	return err;
 }
 
@@ -692,10 +694,8 @@ out:
 	ip_rt_put(rt);
 	if (free)
 		kfree(ipc.opt);
-	if (!err) {
-		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
+	if (!err)
 		return len;
-	}
 	/*
 	 * ENOBUFS = no kernel mem, SOCK_NOSPACE = no sndbuf space.  Reporting
 	 * ENOBUFS might not be good (it's not tunable per se), but otherwise

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
