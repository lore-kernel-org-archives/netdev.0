From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IP] UDP: Use SEQ_START_TOKEN.
Date: Mon, 31 Mar 2008 17:56:52 +0900 (JST)
Message-ID: <20080331.175652.131042307.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55647 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904AbYCaIzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 04:55:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
 net/ipv4/udp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7ea1b67..1704c14 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1556,14 +1556,14 @@ static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(udp_hash_lock)
 {
 	read_lock(&udp_hash_lock);
-	return *pos ? udp_get_idx(seq, *pos-1) : (void *)1;
+	return *pos ? udp_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
 }
 
 static void *udp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct sock *sk;
 
-	if (v == (void *)1)
+	if (v == SEQ_START_TOKEN)
 		sk = udp_get_idx(seq, 0);
 	else
 		sk = udp_get_next(seq, v);
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
