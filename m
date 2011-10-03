From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 07/11] Fix file descriptor leak on error in iproute_flush_cache()
Date: Mon, 03 Oct 2011 17:23:53 +0200
Message-ID: <4E89D389.9080208@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:59721 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664Ab1JCPby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:31:54 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by rs04.intra2net.com (Postfix) with ESMTP id DC499220159
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:16 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id 9C7DE2AC58
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:16 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id BC5EF2AC53
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:14 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 ip/iproute.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 21e1a4b..15b36e8 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1057,6 +1057,7 @@ static int iproute_flush_cache(void)
 
 	if ((write (flush_fd, (void *)buffer, len)) < len) {
 		fprintf (stderr, "Cannot flush routing cache\n");
+		close(flush_fd);
 		return -1;
 	}
 	close(flush_fd);
-- 
1.7.4.4
