From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/9] ila: propagate error code in ila_output
Date: Fri, 19 May 2017 09:55:49 -0700
Message-ID: <20170519165556.483-3-sthemmin@microsoft.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34998 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753058AbdESQ4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:06 -0400
Received: by mail-pg0-f53.google.com with SMTP id q125so40711967pgq.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:06 -0700 (PDT)
In-Reply-To: <20170519165556.483-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This warning:
net/ipv6/ila/ila_lwt.c: In function ‘ila_output’:
net/ipv6/ila/ila_lwt.c:42:6: warning: variable ‘err’ set but not used [-Wunused-but-set-variable]

It looks like the code attempts to set propagate different error
values, but always returned -EINVAL.

Compile tested only. Needs review by original author.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv6/ila/ila_lwt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index b3df03e3faa0..f4a413aba423 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -91,7 +91,7 @@ static int ila_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 drop:
 	kfree_skb(skb);
-	return -EINVAL;
+	return err;
 }
 
 static int ila_input(struct sk_buff *skb)
-- 
2.11.0
