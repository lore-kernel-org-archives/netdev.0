From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 02/11] Fix file descriptor leak on error in rtnl_hash_initialize()
Date: Mon, 03 Oct 2011 17:22:42 +0200
Message-ID: <4E89D342.80801@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:39568 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755088Ab1JCP0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:26:14 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by re04.intra2net.com (Postfix) with ESMTP id 71724300D2
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:13 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id 3D0752AC59
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:13 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id 4D1232AC57
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:12 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 lib/rt_names.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index 30d43cd..a290021 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -54,6 +54,7 @@ rtnl_hash_initialize(char *file, struct rtnl_hash_entry **hash, int size)
 		    sscanf(p, "%d %s #", &id, namebuf) != 2) {
 			fprintf(stderr, "Database %s is corrupted at %s\n",
 				file, p);
+			fclose(fp);
 			return;
 		}
 
@@ -91,6 +92,7 @@ static void rtnl_tab_initialize(char *file, char **tab, int size)
 		    sscanf(p, "%d %s #", &id, namebuf) != 2) {
 			fprintf(stderr, "Database %s is corrupted at %s\n",
 				file, p);
+			fclose(fp);
 			return;
 		}
 
-- 
1.7.4.4
