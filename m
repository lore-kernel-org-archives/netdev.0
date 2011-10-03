From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 10/11] Fix file descriptor leak in do_tunnels_list()
Date: Mon, 03 Oct 2011 17:24:32 +0200
Message-ID: <4E89D3B0.6020603@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:39574 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755721Ab1JCP0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 11:26:18 -0400
Received: from intranator.m.i2n (unknown [172.16.1.99])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by re04.intra2net.com (Postfix) with ESMTP id 99E353014E
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:17 +0200 (CEST)
Received: from localhost (intranator.m.i2n [127.0.0.1])
	by localhost (Postfix) with ESMTP id 6E7472AC53
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:17 +0200 (CEST)
Received: from pikkukde.a.i2n (unknown [192.168.12.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by intranator.m.i2n (Postfix) with ESMTPS id 5330C2AC54
	for <netdev@vger.kernel.org>; Mon,  3 Oct 2011 17:26:16 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 ip/iptunnel.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index f038f0a..3d41a27 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -411,6 +411,7 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 	if (!fgets(buf, sizeof(buf), fp) ||
 	    !fgets(buf, sizeof(buf), fp)) {
 		fprintf(stderr, "/proc/net/dev read error\n");
+		fclose(fp);
 		return -1;
 	}
 
@@ -421,6 +422,7 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 		if ((ptr = strchr(buf, ':')) == NULL ||
 		    (*ptr++ = 0, sscanf(buf, "%s", name) != 1)) {
 			fprintf(stderr, "Wrong format of /proc/net/dev. Sorry.\n");
+			fclose(fp);
 			return -1;
 		}
 		if (sscanf(ptr, "%ld%ld%ld%ld%ld%ld%ld%*d%ld%ld%ld%ld%ld%ld%ld",
@@ -462,6 +464,7 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 		}
 		printf("\n");
 	}
+	fclose(fp);
 	return 0;
 }
 
-- 
1.7.4.4
