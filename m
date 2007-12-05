From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] BRIDGE : br_fdb_fini() should be __exit_refok instead of
 __exit
Date: Wed, 05 Dec 2007 13:41:24 +0100
Message-ID: <47569C74.9020008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020404070106080904010207"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60028 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbXLEMlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 07:41:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020404070106080904010207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David

Building last net-2.6.25 git tree gave me this warning :

WARNING: vmlinux.o(.init.text+0x2a957): Section mismatch: reference to 
.exit.text:br_fdb_fini (between 'br_init' and 'br_fdb_init')

This is because br_init() (marked __init) can call br_fdb_fini() (marked __exit).

I am not sure the following is the right fix, since __exit_refok is quite new, 
and seldom used.

[PATCH] BRIDGE : br_fdb_fini() should be __exit_refok instead of __exit

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------020404070106080904010207
Content-Type: text/plain;
 name="br_fdb_fini.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="br_fdb_fini.patch"

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index eb57502..6caeba5 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -44,7 +44,7 @@ int __init br_fdb_init(void)
 	return 0;
 }
 
-void __exit br_fdb_fini(void)
+void __exit_refok br_fdb_fini(void)
 {
 	kmem_cache_destroy(br_fdb_cache);
 }

--------------020404070106080904010207--
