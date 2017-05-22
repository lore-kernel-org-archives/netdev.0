From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 5/5] sctp: Adjust one function call together with a variable
 assignment
Date: Mon, 22 May 2017 18:41:45 +0200
Message-ID: <197333e8-b528-ef34-bd16-01e415acdf52@users.sourceforge.net>
References: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:54790 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934585AbdEVQm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 12:42:58 -0400
In-Reply-To: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 18:15:12 +0200

The script "checkpatch.pl" pointed information out like the following.

ERROR: do not use assignment in if condition

Thus fix the affected source code place.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/sctp/protocol.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 057479b7bd72..be2fe3ebae78 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -141,7 +141,8 @@ static void sctp_v4_copy_addrlist(struct list_head *addrlist,
 	struct sctp_sockaddr_entry *addr;
 
 	rcu_read_lock();
-	if ((in_dev = __in_dev_get_rcu(dev)) == NULL) {
+	in_dev = __in_dev_get_rcu(dev);
+	if (!in_dev) {
 		rcu_read_unlock();
 		return;
 	}
-- 
2.13.0
