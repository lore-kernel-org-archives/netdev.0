From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 2/2] [IPROUTE2] ss: parse bare integers are port numbers rather than IP addresses
Date: Tue, 11 Sep 2007 16:02:35 -0400
Message-ID: <11895409552209-git-send-email-jheffner@psc.edu>
References: <11895409553082-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:53476 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934092AbXIKUDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 16:03:10 -0400
In-Reply-To: <11895409553082-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: John Heffner <jheffner@psc.edu>
---
 misc/ss.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 5d14f13..d617f6d 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -953,6 +953,10 @@ void *parse_hostcond(char *addr)
 	memset(&a, 0, sizeof(a));
 	a.port = -1;
 
+	/* Special case: integer by itself is considered a port number */
+	if (!get_integer(&a.port, addr, 0))
+		goto out;
+
 	if (fam == AF_UNIX || strncmp(addr, "unix:", 5) == 0) {
 		char *p;
 		a.addr.family = AF_UNIX;
-- 
1.5.3.rc4.29.g74276-dirty

