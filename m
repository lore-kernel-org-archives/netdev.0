From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH] ping: Wrap SO_BINDTODEVICE with the correct capability.
Date: Mon, 12 Nov 2012 14:11:12 +0100
Message-ID: <50A0F570.5090208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283Ab2KLNLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 08:11:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 ping.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ping.c b/ping.c
index 2f70cec..c958f1a 100644
--- a/ping.c
+++ b/ping.c
@@ -316,6 +316,9 @@ main(int argc, char **argv)
 			struct ifreq ifr;
 			memset(&ifr, 0, sizeof(ifr));
 			strncpy(ifr.ifr_name, device, IFNAMSIZ-1);
+
+			enable_capability_raw();
+
 			if (setsockopt(probe_fd, SOL_SOCKET, SO_BINDTODEVICE, device,
strlen(device)+1) == -1) {
 				if (IN_MULTICAST(ntohl(dst.sin_addr.s_addr))) {
 					struct ip_mreqn imr;
@@ -331,6 +334,8 @@ main(int argc, char **argv)
 					}
 				}
 			}
+
+			disable_capability_raw();
 		}

 		if (settos &&
-- 
1.7.11.7
