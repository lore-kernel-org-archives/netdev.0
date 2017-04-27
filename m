From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 2/2] vxlan: do not output confusing error message
Date: Thu, 27 Apr 2017 21:24:36 +0200
Message-ID: <b57f083303e8375336c4d810eca235045a114c88.1493320999.git.jbenc@redhat.com>
References: <cover.1493320999.git.jbenc@redhat.com>
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57636 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162436AbdD0T1i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 15:27:38 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 92B0A7F4BA
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 19:27:37 +0000 (UTC)
In-Reply-To: <cover.1493320999.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The message "Cannot bind port X, err=Y" creates only confusion. In metadata
based mode, failure of IPv6 socket creation is okay if IPv6 is disabled and
no error message should be printed. But when IPv6 tunnel was requested, such
failure is fatal. The vxlan_socket_create does not know when the error is
harmless and when it's not.

Instead of passing such information down to vxlan_socket_create, remove the
message completely. It's not useful. We propagate the error code up to the
user space and the port number comes from the user space. There's nothing in
the message that the process creating vxlan interface does not know.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 118e508f1889..27cba699d83a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2754,8 +2754,6 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 
 	sock = vxlan_create_sock(net, ipv6, port, flags);
 	if (IS_ERR(sock)) {
-		pr_info("Cannot bind port %d, err=%ld\n", ntohs(port),
-			PTR_ERR(sock));
 		kfree(vs);
 		return ERR_CAST(sock);
 	}
-- 
1.8.3.1
