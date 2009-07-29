From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pppoe: fix /proc/net/pppoe
Date: Wed, 29 Jul 2009 11:43:08 +0200
Message-ID: <4A7019AC.5000402@gmail.com>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org> 	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com> 	<20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com> <4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com> <4A6EF0BF.2050801@gmail.com> <4A6EF705.6070403@openvz.org> <4A6EFA35.3060309@gmail.com> <4A6EFB81.4090105@gmail.com> <4A6F017B.4060909@gmail.com> <4A6F397D.6010606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38256 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475AbZG2JnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 05:43:24 -0400
In-Reply-To: <4A6F397D.6010606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found this one by pppoe code inspection, but this is an old bug.

Igor, this wont fix your problem, sorry !

[PATCH] pppoe: fix /proc/net/pppoe

If a socket is hashed in last slot of pppoe hash table (PPPOE_HASH_SIZE-1)
we report it many times (up to filling seq buffer)
(Only the last socket of last slot)


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index f0031f1..5f20902 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -1063,6 +1063,7 @@ static void *pppoe_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	else {
 		int hash = hash_item(po->pppoe_pa.sid, po->pppoe_pa.remote);
 
+		po = NULL;
 		while (++hash < PPPOE_HASH_SIZE) {
 			po = pn->hash_table[hash];
 			if (po)
