From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Add notice about local netns devices
Date: Wed, 25 Feb 2015 15:46:22 +0200
Message-ID: <1424871982-31938-1-git-send-email-vadim4j@gmail.com>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:46578 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbbBYN5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 08:57:45 -0500
Received: by lams18 with SMTP id s18so3955970lam.13
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 05:57:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added some clarification why 'ip link set netns' can not
change network namespace for some kind of devices.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 057125b..5102f75 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -660,14 +660,29 @@ the interface is
 .IR "POINTOPOINT" .
 
 .TP
-.BI netns " PID"
-move the device to the network namespace associated with the process
-.IR "PID".
-
-.TP
-.BI netns " NETNSNAME"
+.BI netns " NETNSNAME " \fR| " PID"
 move the device to the network namespace associated with name
-.IR "NETNSNAME".
+.IR "NETNSNAME " or
+.RI process " PID".
+
+Some devices are not allowed to change network namespace: loopback, bridge,
+ppp, wireless. These are network namespace local devices. In such case
+.B ip
+tool will return "Invalid argument" error. It is possible to find out if device is local
+to a single network namespace by checking
+.B netns-local
+flag in the output of the
+.BR ethtool ":"
+
+.in +8
+.B ethtool -k
+.I DEVICE
+.in -8
+
+To change network namespace for wireless devices the
+.B iw
+tool can be used. But it allows to change network namespace only for physical devices and by process
+.IR PID .
 
 .TP
 .BI alias " NAME"
-- 
2.2.2
