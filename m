From: "Satoru SATOH" <satoru.satoh@gmail.com>
Subject: [PATCH] [IPV4]: Make tcp_input_metrics() get minimum RTO via tcp_rto_min()
Date: Sat, 15 Dec 2007 11:44:46 +0900
Message-ID: <d72b7ace0712141844x6392ceb6y5cb39d9a81f950e6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:63304 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbXLOCor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 21:44:47 -0500
Received: by py-out-1112.google.com with SMTP id u77so1687922pyb.16
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 18:44:47 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_input_metrics() refers to the built-time constant TCP_RTO_MIN
regardless of configured minimum RTO with iproute2.

The following fixes that.


Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b9e429d..889c893 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -923,7 +923,7 @@ static void tcp_init_metrics(struct sock *sk)
 	}
 	if (dst_metric(dst, RTAX_RTTVAR) > tp->mdev) {
 		tp->mdev = dst_metric(dst, RTAX_RTTVAR);
-		tp->mdev_max = tp->rttvar = max(tp->mdev, TCP_RTO_MIN);
+		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 	}
 	tcp_set_rto(sk);
 	tcp_bound_rto(sk);
