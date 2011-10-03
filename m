From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 05/11] Fix memory leak of lname variable in get_target_name()
Date: Mon, 03 Oct 2011 17:23:30 +0200
Message-ID: <4E89D372.3060108@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:59725 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756067Ab1JCPby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:31:54 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by rs04.intra2net.com (Postfix) with ESMTP id 21BE9220142
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:15 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id CA1562AC58
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:14 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id C38882AC54
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:13 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 tc/m_ipt.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tc/m_ipt.c b/tc/m_ipt.c
index 99d9965..a73d400 100644
--- a/tc/m_ipt.c
+++ b/tc/m_ipt.c
@@ -281,6 +281,7 @@ get_target_name(const char *name)
 			fputs(dlerror(), stderr);
 			printf("\n");
 			free(new_name);
+			free(lname);
 			return NULL;
 		}
 	}
@@ -297,6 +298,7 @@ get_target_name(const char *name)
 					fprintf(stderr, "\n");
 					dlclose(handle);
 					free(new_name);
+					free(lname);
 					return NULL;
 				}
 			}
@@ -304,6 +306,7 @@ get_target_name(const char *name)
 	}
 
 	free(new_name);
+	free(lname);
 	return m;
 }
 
-- 
1.7.4.4
