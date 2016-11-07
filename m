From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net-next] igmp: Document sysctl force_igmp_version
Date: Mon,  7 Nov 2016 14:51:23 +0800
Message-ID: <1478501483-6047-1-git-send-email-liuhangbin@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34365 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbcKGGvg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 01:51:36 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so15329243pfb.1
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2016 22:51:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is some difference between force_igmp_version and force_mld_version.
Add document to make users aware of this.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 Documentation/networking/ip-sysctl.txt | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 3db8c67..5af48dd 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -967,6 +967,21 @@ igmp_qrv - INTEGER
 	Default: 2 (as specified by RFC2236 8.1)
 	Minimum: 1 (as specified by RFC6636 4.5)
 
+force_igmp_version - INTEGER
+	0 - (default) No enforcement of a IGMP version, IGMPv1/v2 fallback
+	    allowed. Will back to IGMPv3 mode again if all IGMPv1/v2 Querier
+	    Present timer expires.
+	1 - Enforce to use IGMP version 1. Will also reply IGMPv1 report if
+	    receive IGMPv2/v3 query.
+	2 - Enforce to use IGMP version 2. Will fallback to IGMPv1 if receive
+	    IGMPv1 query message. Will reply report if receive IGMPv3 query.
+	3 - Enforce to use IGMP version 3. The same react with default 0.
+
+	Note: this is not the same with force_mld_version because IGMPv3 RFC3376
+	Security Considerations does not have clear description that we could
+	ignore other version messages completely as MLDv2 RFC3810. So make
+	this value as default 0 is recommended.
+
 conf/interface/*  changes special settings per interface (where
 "interface" is the name of your network interface)
 
-- 
2.5.5
