From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 11/11] Fix file descriptor leak on error in read_igmp()
Date: Mon, 03 Oct 2011 17:24:44 +0200
Message-ID: <4E89D3BC.5050206@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:39575 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517Ab1JCP0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:26:18 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by re04.intra2net.com (Postfix) with ESMTP id D760C30154
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:17 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id AC2022AC53
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:17 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id CCFA22AC57
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:16 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 ip/ipmaddr.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index 5a52c85..3ae9478 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -128,8 +128,10 @@ void read_igmp(struct ma_info **result_p)
 	if (!fp)
 		return;
 	memset(&m, 0, sizeof(m));
-	if (!fgets(buf, sizeof(buf), fp))
+	if (!fgets(buf, sizeof(buf), fp)) {
+		fclose(fp);
 		return;
+	}
 
 	m.addr.family = AF_INET;
 	m.addr.bitlen = 32;
-- 
1.7.4.4
