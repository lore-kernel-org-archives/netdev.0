From: Nelson Elhage <nelhage@ksplice.com>
Subject: [PATCH] econet: Do the correct cleanup after an unprivileged SIOCSIFADDR.
Date: Sun,  5 Dec 2010 17:45:52 -0500
Message-ID: <1291589152-4640-1-git-send-email-nelhage@ksplice.com>
Cc: netdev@vger.kernel.org, Nelson Elhage <nelhage@ksplice.com>,
	stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Phil Blundell <philb@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-6.MIT.EDU ([18.7.68.35]:51376 "EHLO
	dmz-mailsec-scanner-6.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753074Ab0LEWqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 17:46:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to drop the mutex and do a dev_put, so set an error code and break like
the other paths, instead of returning directly.

Cc: stable@kernel.org
Signed-off-by: Nelson Elhage <nelhage@ksplice.com>
---
 net/econet/af_econet.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 13992e1..f180371 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -661,8 +661,10 @@ static int ec_dev_ioctl(struct socket *sock, unsigned int cmd, void __user *arg)
 	err = 0;
 	switch (cmd) {
 	case SIOCSIFADDR:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
+		if (!capable(CAP_NET_ADMIN)) {
+			err = -EPERM;
+			break;
+		}
 
 		edev = dev->ec_ptr;
 		if (edev == NULL) {
-- 
1.7.1.31.g6297e

