From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/4] [IPV6]: Just increment OutDatagrams once per a
 datagram.
Date: Thu, 13 Sep 2007 09:30:58 +0900 (JST)
Message-ID: <20070913.093058.08351675.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44031 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbXIMA33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 20:29:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4210951..c347f3e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -555,6 +555,8 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 out:
 	up->len = 0;
 	up->pending = 0;
+	if (!err)
+		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, up->pcflag);
 	return err;
 }
 
@@ -823,10 +825,8 @@ do_append_data:
 	release_sock(sk);
 out:
 	fl6_sock_release(flowlabel);
-	if (!err) {
-		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
+	if (!err)
 		return len;
-	}
 	/*
 	 * ENOBUFS = no kernel mem, SOCK_NOSPACE = no sndbuf space.  Reporting
 	 * ENOBUFS might not be good (it's not tunable per se), but otherwise

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
