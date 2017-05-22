From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/5] sctp: Use kmalloc_array() in sctp_init()
Date: Mon, 22 May 2017 18:37:19 +0200
Message-ID: <24442429-99f7-7d83-5f56-f84776a81880@users.sourceforge.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 17:20:11 +0200

* A multiplication for the size determination of a memory allocation
  indicated that an array data structure should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of a data structure by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/sctp/protocol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 989a900383b5..2b1a6215bd2f 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1442,6 +1442,6 @@ static __init int sctp_init(void)
 
 	/* Allocate and initialize the endpoint hash table.  */
 	sctp_ep_hashsize = 64;
-	sctp_ep_hashtable =
-		kmalloc(64 * sizeof(struct sctp_hashbucket), GFP_KERNEL);
+	sctp_ep_hashtable = kmalloc_array(64, sizeof(*sctp_ep_hashtable),
+					  GFP_KERNEL);
 	if (!sctp_ep_hashtable) {
-- 
2.13.0
