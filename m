From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PACKET]: Fix sparse warnings in af_packet.c
Date: Mon, 7 Jan 2008 12:01:08 +0100
Message-ID: <20080107120108.06453951.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:50018 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807AbYAGLBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 06:01:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CHECK   net/packet/af_packet.c
net/packet/af_packet.c:1876:14: warning: context imbalance in 'packet_seq_start' - wrong count at exit
net/packet/af_packet.c:1888:13: warning: context imbalance in 'packet_seq_stop' - unexpected unlock

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 43e49f4..b8b827c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1870,6 +1870,7 @@ static inline struct sock *packet_seq_idx(struct net *net, loff_t off)
 }
 
 static void *packet_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(seq_file_net(seq)->packet.sklist_lock)
 {
 	struct net *net = seq_file_net(seq);
 	read_lock(&net->packet.sklist_lock);
@@ -1886,6 +1887,7 @@ static void *packet_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void packet_seq_stop(struct seq_file *seq, void *v)
+	__releases(seq_file_net(seq)->packet.sklist_lock)
 {
 	struct net *net = seq_file_net(seq);
 	read_unlock(&net->packet.sklist_lock);
