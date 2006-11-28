From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 1/1] [INET]: Change protocol field in struct inet_protosw to u16
Date: Tue, 28 Nov 2006 03:14:11 -0200
Message-ID: <20061128051410.GE4029@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:19409 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S935594AbWK1FOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 00:14:19 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

	Last one tonight, please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.20.git

- Arnaldo

[acme@newtoy net-2.6.20]$ pahole /tmp/tcp_ipv6.o inet_protosw
/* /pub/scm/linux/kernel/git/acme/net-2.6.20/include/net/protocol.h:69 */
struct inet_protosw {
        struct list_head           list;                 /*     0     8 */
        short unsigned int         type;                 /*     8     2 */

        /* XXX 2 bytes hole, try to pack */

        int                        protocol;             /*    12     4 */
        struct proto *             prot;                 /*    16     4 */
        const struct proto_ops  *  ops;                  /*    20     4 */
        int                        capability;           /*    24     4 */
        char                       no_check;             /*    28     1 */
        unsigned char              flags;                /*    29     1 */
}; /* size: 32, sum members: 28, holes: 1, sum holes: 2, padding: 2 */

So that we can kill that hole, protocol can only go all the way to 255 (RAW).

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/net/protocol.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 28c4cac..105bf12 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -71,7 +71,7 @@ struct inet_protosw {
 
         /* These two fields form the lookup key.  */
 	unsigned short	 type;	   /* This is the 2nd argument to socket(2). */
-	int		 protocol; /* This is the L4 protocol number.  */
+	unsigned short	 protocol; /* This is the L4 protocol number.  */
 
 	struct proto	 *prot;
 	const struct proto_ops *ops;
-- 
1.4.2.1.g3d5c

