From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : Suspicious locking in reqsk_queue_hash_req()
Date: Mon, 16 Oct 2006 11:07:19 +0200
Message-ID: <200610161107.19771.dada1@cosmosbay.com>
References: <20061010.191547.83619974.davem@davemloft.net> <200610111511.19028.dada1@cosmosbay.com> <200610161100.22549.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Hv0MFyO+Ye/e4Wn"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:24968 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1161261AbWJPJHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 05:07:23 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <200610161100.22549.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_Hv0MFyO+Ye/e4Wn
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

(Sorry, patch inlined this time)

Hi David

While browsing include/net/request_sock.h I found this suspicious locking
protecting the SYN table hash table. I think this patch is necessary.

Thank you

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_Hv0MFyO+Ye/e4Wn
Content-Type: text/plain;
  charset="utf-8";
  name="reqsk_queue_hash_req.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="reqsk_queue_hash_req.patch"

--- linux-2.6.18/include/net/request_sock.h.orig	2006-10-16 10:53:11.000000000 +0200
+++ linux-2.6.18-ed/include/net/request_sock.h	2006-10-16 10:53:24.000000000 +0200
@@ -251,9 +251,9 @@
 	req->expires = jiffies + timeout;
 	req->retrans = 0;
 	req->sk = NULL;
-	req->dl_next = lopt->syn_table[hash];
 
 	write_lock(&queue->syn_wait_lock);
+	req->dl_next = lopt->syn_table[hash];
 	lopt->syn_table[hash] = req;
 	write_unlock(&queue->syn_wait_lock);
 }

--Boundary-00=_Hv0MFyO+Ye/e4Wn--
