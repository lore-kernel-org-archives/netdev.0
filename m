From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 09/11] Fix file descriptor leak on error in read_mroute_list()
Date: Mon, 03 Oct 2011 17:24:18 +0200
Message-ID: <4E89D3A2.1060605@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:59724 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754869Ab1JCPby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:31:54 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by rs04.intra2net.com (Postfix) with ESMTP id 1067722015A
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:17 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id C32502AC53
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:16 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id D0FA72AC57
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:15 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 ip/ipmroute.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index f033349..945727d 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -85,8 +85,10 @@ static void read_mroute_list(FILE *ofp)
 	if (!fp)
 		return;
 
-	if (!fgets(buf, sizeof(buf), fp))
+	if (!fgets(buf, sizeof(buf), fp)) {
+		fclose(fp);
 		return;
+	}
 
 	while (fgets(buf, sizeof(buf), fp)) {
 		inet_prefix maddr, msrc;
-- 
1.7.4.4
