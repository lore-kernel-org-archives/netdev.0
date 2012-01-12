From: Bradley Peterson <despite@gmail.com>
Subject: [PATCH] pptp: Accept packet with seq zero
Date: Thu, 12 Jan 2012 14:39:16 -0600
Message-ID: <1326400756-14021-1-git-send-email-despite@gmail.com>
Cc: Bradley Peterson <despite@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xeb@mail.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initialize the PPTP "seq received" value to 0xffffffff, so we don't
ignore packets with seq zero.

Signed-off-by: Bradley Peterson <despite@gmail.com>
---
 drivers/net/ppp/pptp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index c1c9293..df884dd 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -585,8 +585,8 @@ static int pptp_create(struct net *net, struct socket *sock)
 	po = pppox_sk(sk);
 	opt = &po->proto.pptp;
 
-	opt->seq_sent = 0; opt->seq_recv = 0;
-	opt->ack_recv = 0; opt->ack_sent = 0;
+	opt->seq_sent = 0; opt->seq_recv = 0xffffffff;
+	opt->ack_recv = 0; opt->ack_sent = 0xffffffff;
 
 	error = 0;
 out:
-- 
1.7.4.4
