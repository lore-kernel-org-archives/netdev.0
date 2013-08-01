From: Cong Wang <amwang@redhat.com>
Subject: =?UTF-8?q?=5BPatch=20net-next=201/2=5D=20net=3A=20fix=20a=20compile=20error=20when=20CONFIG=5FNET=5FLL=5FRX=5FPOLL=20is=20not=20set?=
Date: Thu,  1 Aug 2013 11:10:24 +0800
Message-ID: <1375326625-21427-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751083Ab3HADKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 23:10:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Cong Wang <amwang@redhat.com>

When CONFIG_NET_LL_RX_POLL is not set, I got:

net/socket.c: In function =E2=80=98sock_poll=E2=80=99:
net/socket.c:1165:4: error: implicit declaration of function =E2=80=98s=
k_busy_loop=E2=80=99 [-Werror=3Dimplicit-function-declaration]

=46ix this by adding a nop when !CONFIG_NET_LL_RX_POLL.

Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index a14339c..6cd8848 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -181,5 +181,10 @@ static inline bool busy_loop_timeout(unsigned long=
 end_time)
 	return true;
 }
=20
+static inline bool sk_busy_loop(struct sock *sk, int nonblock)
+{
+	return false;
+}
+
 #endif /* CONFIG_NET_LL_RX_POLL */
 #endif /* _LINUX_NET_BUSY_POLL_H */
