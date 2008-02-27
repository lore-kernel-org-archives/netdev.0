From: Patrick McManus <mcmanus@ducksong.com>
Subject: RFC [PATCH 1/3] TCP_DEFER_ACCEPT updates: defer timeouts conflict
	with max_thresh
Date: Tue, 26 Feb 2008 20:49:01 -0500
Message-ID: <1204076941.15970.34.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McManus <mcmanus@ducksong.com>

    timeout associated with SO_DEFER_ACCEPT wasn't being honored if it was
    less than the timeout allowed by the maximum syn-recv queue size
    algorithm. Fix by using the SO_DEFER_ACCEPT value if the ack has
    arrived.

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index b189278..03cc323 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -461,8 +461,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
                reqp=&lopt->syn_table[i];
                while ((req = *reqp) != NULL) {
                        if (time_after_eq(now, req->expires)) {
-                               if ((req->retrans < thresh ||
-                                    (inet_rsk(req)->acked && req->retrans < max_retries))
+                               if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh))
                                    && !req->rsk_ops->rtx_syn_ack(parent, req, NULL)) {
                                        unsigned long timeo;



