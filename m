From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 5/5] ethtool: Report pause auto-negotiation flags
Date: Thu, 30 Apr 2009 13:38:06 +0100
Message-ID: <1241095086.3185.12.camel@achroite>
References: <1241094796.3185.2.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:37304 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762243AbZD3MiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 08:38:07 -0400
In-Reply-To: <1241094796.3185.2.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 0d188af..c40603c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -891,6 +891,19 @@ static void dump_advertised(struct ethtool_cmd *ep,
 		 fprintf(stdout, "Not reported");
 	fprintf(stdout, "\n");
 
+	fprintf(stdout, "	%s pause frame use: ", prefix);
+	if (mask & ADVERTISED_Pause) {
+		fprintf(stdout, "Symmetric");
+		if (mask & ADVERTISED_Asym_Pause)
+			fprintf(stdout, " Receive-only");
+		fprintf(stdout, "\n");
+	} else {
+		if (mask & ADVERTISED_Asym_Pause)
+			fprintf(stdout, "Transmit-only\n");
+		else
+			fprintf(stdout, "No\n");
+	}
+
 	fprintf(stdout, "	%s auto-negotiation: ", prefix);
 	if (mask & ADVERTISED_Autoneg)
 		fprintf(stdout, "Yes\n");

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

