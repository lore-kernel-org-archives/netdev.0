From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] net, compat_ioctl: fix SIOCGMII ioctls
Date: Sun, 8 Nov 2009 22:34:13 +0100
Message-ID: <200911082234.14031.arnd@arndb.de>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de> <20091106.204753.223665411.davem@davemloft.net> <200911082231.48060.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@lst.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:60681 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376AbZKHVeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 16:34:17 -0500
In-Reply-To: <200911082231.48060.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIOCGMIIPHY and SIOCGMIIREG return data through ifreq,
so it needs to be converted on the way out as well.

SIOCGIFPFLAGS is unused, but has the same problem in theory.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/socket.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 688de5d..28a0263 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2587,7 +2587,10 @@ static int dev_ifsioc(struct net *net, struct socket *sock,
 		case SIOCGIFBRDADDR:
 		case SIOCGIFDSTADDR:
 		case SIOCGIFNETMASK:
+		case SIOCGIFPFLAGS:
 		case SIOCGIFTXQLEN:
+		case SIOCGMIIPHY:
+		case SIOCGMIIREG:
 			if (copy_to_user(uifr32, &ifr, sizeof(*uifr32)))
 				return -EFAULT;
 			break;
-- 
1.6.3.3



