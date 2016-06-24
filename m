From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ip-address, ip-link: Document 'type' quirk
Date: Fri, 24 Jun 2016 12:14:23 +0200
Message-ID: <1466763263-1994-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60063 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853AbcFXKOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 06:14:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers the fact that calling 'ip {link|addr} show type foobar' does
not return an error.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-address.8.in | 6 ++++++
 man/man8/ip-link.8.in    | 6 ++++++
 2 files changed, 12 insertions(+)

diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index ab0942d7e94e2..8d34adb336af4 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -280,6 +280,12 @@ only list interfaces enslaved to this master device.
 .BI type " TYPE"
 only list interfaces of the given type.
 
+Note that the type name is not checked against the list of supported types -
+instead it is sent as-is to the kernel. Later it is used to filter the returned
+interface list by comparing it with the relevant attribute in case the kernel
+didn't filter already. Therefore any string is accepted, but may lead to empty
+output.
+
 .TP
 .B up
 only list running interfaces.
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index d5673639d9ddf..e10f541b20bcf 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1242,6 +1242,12 @@ specifies the master device which enslaves devices to show.
 .I TYPE
 specifies the type of devices to show.
 
+Note that the type name is not checked against the list of supported types -
+instead it is sent as-is to the kernel. Later it is used to filter the returned
+interface list by comparing it with the relevant attribute in case the kernel
+didn't filter already. Therefore any string is accepted, but may lead to empty
+output.
+
 .SS  ip link help - display help
 
 .PP
-- 
2.8.2
