From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 03/12] Prevent renaming interfaces to empty string.
Date: Fri, 12 Oct 2007 10:56:38 +0200
Message-ID: <1192179407-22461-3-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
 <1192179407-22461-2-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38397 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbXJLI5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:57:33 -0400
In-Reply-To: <1192179407-22461-2-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Wirt <formorer@debian.org>


Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 ip/iplink.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 4060845..da1f64e 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -670,6 +670,10 @@ static int do_set(int argc, char **argv)
 	}
 
 	if (newname && strcmp(dev, newname)) {
+		if (strlen(newname) == 0) {
+		    printf("\"\" is not valid device identifier\n");
+		    return -1;
+		}
 		if (do_changename(dev, newname) < 0)
 			return -1;
 		dev = newname;
-- 
1.5.3.4

