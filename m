From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH 1/3] man: macsec: fix macsec related typos
Date: Tue, 26 Jul 2016 11:03:18 +0200
Message-ID: <dad1f2b9e3b1edb0119da2edab4957d8b94e2005.1469520298.git.dcaratti@redhat.com>
References: <cover.1469520298.git.dcaratti@redhat.com>
Cc: Phil Sutter <phil@nwl.cc>, Sabrina Dubroca <sd@queasysnail.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755064AbcGZJE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 05:04:27 -0400
In-Reply-To: <cover.1469520298.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- ip-macsec.8: fix wrong 'device' keyword in 'ip link add device eth0';
add missing description of 'validate' keyword; remove spurious bracket
near 'encrypt' keyword; add missing reference to configuration of 'port'
and 'sci'
- ip-link.8 fix wrong 'es' and 'encoding' keywords in MACsec section

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 man/man8/ip-link.8.in |  8 ++++----
 man/man8/ip-macsec.8  | 11 ++++++++---
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 2cd6133..c91ef95 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -925,14 +925,14 @@ the following additional arguments are supported:
 .BR encrypt " {"
 .BR on " | " off " } ] [ "
 .BR send_sci " { " on " | " off " } ] ["
-.BR es " { " on " | " off " } ] ["
+.BR end_station " { " on " | " off " } ] ["
 .BR scb " { " on " | " off " } ] ["
 .BR protect " { " on " | " off " } ] ["
 .BR replay " { " on " | " off " }"
 .BR window " { "
 .IR 0..2^32-1 " } ] ["
 .BR validate " { " strict " | " check " | " disabled " } ] ["
-.BR encoding " { "
+.BR encodingsa " { "
 .IR 0..3 " } ]"
 
 .in +8
@@ -957,7 +957,7 @@ the following additional arguments are supported:
 - specifies whether the SCI is included in every packet, or only when it is necessary.
 
 .sp
-.BR "es on " or " es off"
+.BR "end_station on " or " end_station off"
 - sets the End Station bit.
 
 .sp
@@ -985,7 +985,7 @@ the following additional arguments are supported:
 - sets the validation mode on the device.
 
 .sp
-.BI encoding " AN "
+.BI encodingsa " AN "
 - sets the active secure association for transmission.
 
 .in -8
diff --git a/man/man8/ip-macsec.8 b/man/man8/ip-macsec.8
index e8455d7..f928c43 100644
--- a/man/man8/ip-macsec.8
+++ b/man/man8/ip-macsec.8
@@ -3,10 +3,14 @@
 ip-macsec \- MACsec device configuration
 .SH "SYNOPSIS"
 .BI "ip link add link " DEVICE " name " NAME " type macsec "
-[ [
+[
+.BI port " PORT"
+|
+.BI sci  " SCI"
+] [ [
 .BR cipher " { " default " | " gcm-aes-128 " } ] "
 .BI icvlen " ICVLEN"
-] [ [
+] [
 .BR encrypt " { " on " | " off " } ] ["
 .BR send_sci " { " on " | " off " } ] ["
 .BR end_station " { " on " | " off " } ] ["
@@ -15,6 +19,7 @@ ip-macsec \- MACsec device configuration
 .BR replay " { " on " | " off " } ] ["
 .BI window " WINDOW"
 ] [
+.BR validate " { " strict " | " check " | " disabled " } ] ["
 .BI encodingsa " SA"
 ]
 
@@ -74,7 +79,7 @@ type.
 .PP
 .SS Create a MACsec device on link eth0
 .nf
-# ip link add device eth0 macsec0 type macsec port 11 encrypt on
+# ip link add link eth0 macsec0 type macsec port 11 encrypt on
 .PP
 .SS Configure a secure association on that device
 .nf
-- 
2.5.5
