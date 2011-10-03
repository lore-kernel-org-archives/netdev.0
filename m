From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 01/11] Fix pipe I/O stream descriptor leak in init_service_resolver()
Date: Mon, 03 Oct 2011 17:22:27 +0200
Message-ID: <4E89D333.70301@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:39569 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755721Ab1JCP0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:26:14 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by re04.intra2net.com (Postfix) with ESMTP id E893730147
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:13 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id B8FDD2AC59
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:13 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id 8B2E62AC54
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:11 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 misc/ss.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 1597ff9..f62d371 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -518,6 +518,7 @@ void init_service_resolver(void)
 				}
 			}
 		}
+		pclose(fp);
 	}
 }
 
-- 
1.7.4.4
