From: ahendry <ahendry@tusc.com.au>
Subject: [PATCH] X.25 Add missing sock_put in x25_receive_data
Date: Tue, 09 Jan 2007 09:32:17 +1100
Message-ID: <1168295537.5460.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-x25-owner@vger.kernel.org>
To: linux-x25@vger.kernel.org, eis@baty.hanse.de
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


__x25_find_socket does a sock_hold.
This adds a missing sock_put in x25_receive_data.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

--- linux-2.6.19-vanilla/net/x25/x25_dev.c	2006-12-31 22:31:07.000000000 +1100
+++ linux-2.6.19/net/x25/x25_dev.c	2007-01-06 16:40:54.000000000 +1100
@@ -56,6 +56,7 @@ static int x25_receive_data(struct sk_bu
 			sk_add_backlog(sk, skb);
 		}
 		bh_unlock_sock(sk);
+		sock_put(sk);
 		return queued;
 	}

