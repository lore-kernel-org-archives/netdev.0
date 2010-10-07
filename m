From: John Heffner <johnwheffner@gmail.com>
Subject: [PATCH] TCP: Fix setting of snd_ssthresh in tcp_mtu_probe_success
Date: Wed,  6 Oct 2010 23:41:53 -0400
Message-ID: <1286422913-30034-1-git-send-email-johnwheffner@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:40775 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430Ab0JGDl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 23:41:57 -0400
Received: by qwf7 with SMTP id 7so123400qwf.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 20:41:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This looks like a simple typo that has gone unnoticed for some time.  The
impact is relatively low but it's clearly wrong.

Signed-off-by: John Heffner <johnwheffner@gmail.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f6fdd72..e4fbdae 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2874,7 +2874,7 @@ static void tcp_mtup_probe_success(struct sock *sk)
 		       icsk->icsk_mtup.probe_size;
 	tp->snd_cwnd_cnt = 0;
 	tp->snd_cwnd_stamp = tcp_time_stamp;
-	tp->rcv_ssthresh = tcp_current_ssthresh(sk);
+	tp->snd_ssthresh = tcp_current_ssthresh(sk);
 
 	icsk->icsk_mtup.search_low = icsk->icsk_mtup.probe_size;
 	icsk->icsk_mtup.probe_size = 0;
-- 
1.7.0.4

