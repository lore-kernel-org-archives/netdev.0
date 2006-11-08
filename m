From: Ralf Baechle <ralf@linux-mips.org>
Subject: [DECnet] Don't clear memory twice.
Date: Wed, 8 Nov 2006 15:45:07 +0000
Message-ID: <20061108154506.GA20057@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SteveW@ACM.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:64736 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S965925AbWKHPoz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 10:44:55 -0500
Received: from localhost.localdomain ([127.0.0.1]:33728 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20039772AbWKHPox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 15:44:53 +0000
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When dn_neigh.c was converted from kmalloc to kzalloc in commit
0da974f4f303a6842516b764507e3c0a03f41e5a it was missed that
dn_neigh_seq_open was actually clearing the allocation twice was
missed.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index ff0ebe9..7322bb3 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -591,7 +591,6 @@ static int dn_neigh_seq_open(struct inod
 
 	seq          = file->private_data;
 	seq->private = s;
-	memset(s, 0, sizeof(*s));
 out:
 	return rc;
 out_kfree:
