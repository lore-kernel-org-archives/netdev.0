From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 08/11] Fix file descriptor leak on error in read_viftable()
Date: Mon, 03 Oct 2011 17:24:08 +0200
Message-ID: <4E89D398.50703@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:39572 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756493Ab1JCP0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:26:17 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by re04.intra2net.com (Postfix) with ESMTP id 62D5930147
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:16 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id 336992AC59
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:16 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id 4EAA72AC54
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:15 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 ip/ipmroute.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index a4389f5..f033349 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -58,9 +58,10 @@ static void read_viftable(void)
 	if (!fp)
 		return;
 
-	if (!fgets(buf, sizeof(buf), fp))
+	if (!fgets(buf, sizeof(buf), fp)) {
+		fclose(fp);
 		return;
-
+	}
 	while (fgets(buf, sizeof(buf), fp)) {
 		int vifi;
 		char dev[256];
-- 
1.7.4.4
