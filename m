From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 6/6] rtnetlink: do not set notification for tx_queue_len in do_setlink
Date: Sun, 15 Oct 2017 18:13:46 +0800
Message-ID: <6337bdec4b0564c0577f90703ea840fd3580912a.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
 <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
 <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
 <784f477a1f9e8b9a5ec7bbe9e1dff1dcdfd5553b.1508062280.git.lucien.xin@gmail.com>
 <22c0aefe18d4451166c5f12714d8520346a63f2b.1508062280.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, David Ahern <dsahern@gmail.com>,
        hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:48128 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750829AbdJOKOn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 06:14:43 -0400
Received: by mail-pf0-f196.google.com with SMTP id b79so13656742pfk.5
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 03:14:43 -0700 (PDT)
In-Reply-To: <22c0aefe18d4451166c5f12714d8520346a63f2b.1508062280.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETDEV_CHANGE_TX_QUEUE_LEN event process in rtnetlink_event would
send a notification for userspace and tx_queue_len's setting in
do_setlink would trigger NETDEV_CHANGE_TX_QUEUE_LEN.

So it shouldn't set DO_SETLINK_NOTIFY status for this change to
send a notification any more.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 3e98fb5..a6bcf86 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2093,7 +2093,7 @@ static int do_setlink(const struct sk_buff *skb,
 				dev->tx_queue_len = orig_len;
 				goto errout;
 			}
-			status |= DO_SETLINK_NOTIFY;
+			status |= DO_SETLINK_MODIFIED;
 		}
 	}
 
-- 
2.1.0
