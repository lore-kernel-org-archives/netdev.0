From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 1/2] socket: increase default maximum listen queue length
Date: Fri, 25 Mar 2011 19:31:38 +0100
Message-ID: <1301077899-16482-1-git-send-email-hagen@jauu.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:37363 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754525Ab1CYScI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 14:32:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sysctl_somaxconn specifies the maximum number of sockets in state
SYN_RECV per listen socket and is initialized with 128 (SOMAXCONN).

sysctl_max_syn_backlog on the other hand provides similar functionality:
provides a system wide upper limit of request sockets per listen socket.
But sysctl_max_syn_backlog provides a more accurate value by considerate
the actual memory situation of the system. 256 by default, 128 for
systems with low memory and up to 1024 for larger systems.

This patch increase sysctl_somaxconn to 256 and provide environments with
a increased RTT and many connections/second a better default value by
simultaneously provides the fallback that smaller systems will not suffer
of an increased memory usage - sysctl_max_syn_backlog is already a good
guard.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/socket.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index edbb1d0..bf35ce2 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -237,7 +237,7 @@ struct ucred {
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
-#define SOMAXCONN	128
+#define SOMAXCONN	256
 
 /* Flags we can use with send/ and recv. 
    Added those for 1003.1g not all are supported yet
-- 
1.7.2.3

