From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH v3] bonding: document two undocumented options.
Date: Sat,  6 Aug 2011 19:06:39 +0200
Message-ID: <1312650399-5165-1-git-send-email-nicolas.2p.debian@free.fr>
References: <3571.1312405193@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.smtpout.orange.fr ([80.12.242.125]:39769 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644Ab1HFRO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 13:14:58 -0400
In-Reply-To: <3571.1312405193@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 655f8919d549ad1872e24d826b6ce42530516d2e
    bonding: add min links parameter to 802.3ad

and commit ebd8e4977a87cb81d93c62a9bff0102a9713722f
    bonding: add all_slaves_active parameter

introduced new options to bonding, but didn't provide the documentation
for those options.

V2: add the default value for both options.
V3: document the exact behavior of min_links default value.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 Documentation/networking/bonding.txt |   29 ++++++++++++++++++++++++++=
+++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/netwo=
rking/bonding.txt
index 675612f..dc4ea85 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -238,6 +238,18 @@ ad_select
=20
 	This option was added in bonding version 3.4.0.
=20
+all_slaves_active
+
+	Specifies that duplicate frames (received on inactive ports) should b=
e
+	dropped (0) or delivered (1).=20
+
+	Normally, bonding will drop duplicate frames (received on inactive
+	ports), which is desirable for most users. But there are some times
+	it is nice to allow duplicate frames to be delivered.
+
+	The default value is 0 (drop duplicate frames received on inactive
+	ports).
+
 arp_interval
=20
 	Specifies the ARP link monitoring frequency in milliseconds.
@@ -433,6 +445,23 @@ miimon
 	determined.  See the High Availability section for additional
 	information.  The default value is 0.
=20
+min_links
+
+	Specifies the minimum number of links that must be active before
+	asserting carrier. It is similar to the Cisco EtherChannel min-links
+	feature. This allows setting the minimum number of member ports that
+	must be up (link-up state) before marking the bond device as up
+	(carrier on). This is useful for situations where higher level servic=
es
+	such as clustering want to ensure a minimum number of low bandwidth
+	links are active before switchover. This option only affect 802.3ad
+	mode.=20
+
+	The default value is 0. This will cause carrier to be asserted (for
+	802.3ad mode) whenever there is an active aggregator, regardless of t=
he
+	number of available links in that aggregator. Note that, because an
+	aggregator cannot be active without at least one available link,
+	setting this option to 0 or to 1 has the exact same effect.
+
 mode
=20
 	Specifies one of the bonding policies. The default is
--=20
1.7.5.4

