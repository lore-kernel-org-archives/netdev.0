From: Lifeng Sun <lifongsun@gmail.com>
Subject: [PATCH 1/5] networking: inappropriate ioctl operation should return ENOTTY
Date: Thu, 28 Apr 2011 16:04:51 +0800
Message-ID: <1303977891-29280-1-git-send-email-lifongsun@gmail.com>
References: <20110427130904.47331a9f@lxorguk.ukuu.org.uk>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Lifeng Sun <lifongsun@gmail.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110427130904.47331a9f@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ioctl() calls against a socket with an inappropriate ioctl operation
are incorrectly returning EINVAL rather than ENOTTY:

  [ENOTTY]
      Inappropriate I/O control operation.

BugLink: https://bugzilla.kernel.org/show_bug.cgi?id=33992

Signed-off-by: Lifeng Sun <lifongsun@gmail.com>
---
 net/core/dev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c2ac599..856b6ee 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4773,7 +4773,7 @@ static int dev_ifsioc_locked(struct net *net, struct ifreq *ifr, unsigned int cm
 		 * is never reached
 		 */
 		WARN_ON(1);
-		err = -EINVAL;
+		err = -ENOTTY;
 		break;
 
 	}
@@ -5041,7 +5041,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		/* Set the per device memory buffer space.
 		 * Not applicable in our case */
 	case SIOCSIFLINK:
-		return -EINVAL;
+		return -ENOTTY;
 
 	/*
 	 *	Unknown or private ioctl.
@@ -5062,7 +5062,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		/* Take care of Wireless Extensions */
 		if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
 			return wext_handle_ioctl(net, &ifr, cmd, arg);
-		return -EINVAL;
+		return -ENOTTY;
 	}
 }
 
-- 
1.7.5.rc1
