From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v2] CAN: Use inode instead of kernel address for /proc file
Date: Sun, 26 Dec 2010 11:54:53 -0500
Message-ID: <1293382493.9764.54.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:51082 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358Ab0LZQzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Dec 2010 11:55:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the socket address is just being used as a unique identifier, its
inode number is an alternative that does not leak potentially sensitive
information.

CC-ing stable because MITRE has assigned CVE-2010-4565 to the issue.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: stable <stable@kernel.org>
---
 net/can/bcm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 6faa825..bc51b56 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -125,7 +125,7 @@ struct bcm_sock {
 	struct list_head tx_ops;
 	unsigned long dropped_usr_msgs;
 	struct proc_dir_entry *bcm_proc_read;
-	char procname [20]; /* pointer printed in ASCII with \0 */
+	char procname [32]; /* inode number in decimal with \0 */
 };
 
 static inline struct bcm_sock *bcm_sk(const struct sock *sk)
@@ -1521,7 +1521,7 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 
 	if (proc_dir) {
 		/* unique socket address as filename */
-		sprintf(bo->procname, "%p", sock);
+		sprintf(bo->procname, "%lu", sock_i_ino(sk));
 		bo->bcm_proc_read = proc_create_data(bo->procname, 0644,
 						     proc_dir,
 						     &bcm_proc_fops, sk);


