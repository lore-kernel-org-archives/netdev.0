From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Fix recommended permissions for /dev/net/tun
Date: Tue, 20 Jun 2006 16:35:22 +0100
Message-ID: <1150817723.17609.81.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34178 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751324AbWFTPfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 11:35:13 -0400
Received: from nat-pool-stn.redhat.com ([62.200.124.98] helo=hades.cambridge.redhat.com)
	by pentafluge.infradead.org with esmtpsa (Exim 4.62 #1 (Red Hat Linux))
	id 1FsiG0-00036D-9h
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 16:35:12 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no reason to restrict unprivileged users from opening
the /dev/net/tun device node -- to do anything exciting requires
CAP_NET_ADMIN or a persistent device which is owned by the user in
question anyway. And if it _isn't_ openable by unprivileged users, then
giving ownership of devices to those users is a fairly pointless
exercise.

Signed-Off-By: David Woodhouse <dwmw2@infradead.org>

diff --git a/Documentation/networking/tuntap.txt b/Documentation/networking/tuntap.txt
index 76750fb..9d696f2 100644
--- a/Documentation/networking/tuntap.txt
+++ b/Documentation/networking/tuntap.txt
@@ -39,10 +39,13 @@ Copyright (C) 1999-2000 Maxim Krasnyansk
      mknod /dev/net/tun c 10 200
   
   Set permissions:
-     e.g. chmod 0700 /dev/net/tun
-     if you want the device only accessible by root. Giving regular users the
-     right to assign network devices is NOT a good idea. Users could assign
-     bogus network interfaces to trick firewalls or administrators.
+     e.g. chmod 0666 /dev/net/tun
+     There's no harm in allowing the device to be accessible by non-root users,
+     since CAP_NET_ADMIN is required for creating network devices or for 
+     connecting to network devices which aren't owned by the user in question.
+     If you want to create persistent devices and give ownership of them to 
+     unprivileged users, then you need the /dev/net/tun device to be usable by
+     those users.
 
   Driver module autoloading
 


-- 
dwmw2

