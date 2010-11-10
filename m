From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: can-bcm: fix minor heap overflow
Date: Wed, 10 Nov 2010 23:10:30 +0100
Message-ID: <4CDB1856.4040001@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Dan Rosenberg <drosenberg@vsecurity.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Urs Thuermann <urs@isnogud.escape.de>, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:45658 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014Ab0KJWLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 17:11:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 64-bit platforms the ASCII representation of a pointer may be up to 17
bytes long. This patch increases the length of the buffer accordingly.

http://marc.info/?l=linux-netdev&m=128872251418192&w=2

Reported-by: Dan Rosenberg <drosenberg@vsecurity.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
CC: Linus Torvalds <torvalds@linux-foundation.org>

---

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 08ffe9e..6faa825 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -125,7 +125,7 @@ struct bcm_sock {
 	struct list_head tx_ops;
 	unsigned long dropped_usr_msgs;
 	struct proc_dir_entry *bcm_proc_read;
-	char procname [9]; /* pointer printed in ASCII with \0 */
+	char procname [20]; /* pointer printed in ASCII with \0 */
 };

 static inline struct bcm_sock *bcm_sk(const struct sock *sk)

