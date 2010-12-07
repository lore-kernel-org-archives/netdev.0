From: Dan Carpenter <error27@gmail.com>
Subject: [patch] econet: unlock on -EPERM path
Date: Tue, 7 Dec 2010 14:01:38 +0300
Message-ID: <20101207110138.GM10623@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Blundell <philb@gnu.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44113 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347Ab0LGLCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 06:02:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to do a mutex_unlock() and a put_dev() before returning.

Signed-off-by: Dan Carpenter <error27@gmail.com>

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
