From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH net v2 3/3] net/packet: fix overflow in check for tp_reserve
Date: Wed, 29 Mar 2017 16:11:22 +0200
Message-ID: <b6e7f64aa4f58db0c879510e86196534e472f857.1490796500.git.andreyknvl@google.com>
References: <cover.1490796500.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:33380 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752148AbdC2OLk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 10:11:40 -0400
Received: by mail-wr0-f174.google.com with SMTP id w43so17224602wrb.0
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 07:11:39 -0700 (PDT)
In-Reply-To: <cover.1490796500.git.andreyknvl@google.com>
In-Reply-To: <cover.1490796500.git.andreyknvl@google.com>
References: <cover.1490796500.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When calculating po->tp_hdrlen + po->tp_reserve the result can overflow.

Fix by checking that tp_reserve <= INT_MAX on assign.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/packet/af_packet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 3ac286ebb2f4..8489beff5c25 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3665,6 +3665,8 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 			return -EBUSY;
 		if (copy_from_user(&val, optval, sizeof(val)))
 			return -EFAULT;
+		if (val > INT_MAX)
+			return -EINVAL;
 		po->tp_reserve = val;
 		return 0;
 	}
-- 
2.12.2.564.g063fe858b8-goog
