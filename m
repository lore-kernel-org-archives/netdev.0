From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6] Add missing ioctls to 64<->32 conversion
Date: Thu, 22 Mar 2007 17:26:49 -0700
Message-ID: <20070323002649.GB2712@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jouni Malinen <jkm@devicescape.com>
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:62174 "EHLO
	gundega.hpl.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbXCWA1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 20:27:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi John,

	Johannes Berg and Michael Buesch noticed that the WPA ioctls
were missing from the 64<->32 bit conversion. This means that when
using a 32 bits userspace on a 64 bit kernel, those ioctls fail.
	This patch was tested on 2.6.21-rc4. Would you mind pushing it
upstream ?
	Thanks...

	Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/fs/compat_ioctl.j1.c  linux/fs/compat_ioctl.c
--- linux/fs/compat_ioctl.j1.c	2007-03-06 17:49:33.000000000 -0800
+++ linux/fs/compat_ioctl.c	2007-03-06 17:56:19.000000000 -0800
@@ -2553,11 +2553,15 @@ HANDLE_IOCTL(I2C_RDWR, do_i2c_rdwr_ioctl
 HANDLE_IOCTL(I2C_SMBUS, do_i2c_smbus_ioctl)
 /* wireless */
 HANDLE_IOCTL(SIOCGIWRANGE, do_wireless_ioctl)
+HANDLE_IOCTL(SIOCGIWPRIV, do_wireless_ioctl)
+HANDLE_IOCTL(SIOCGIWSTATS, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCSIWSPY, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCGIWSPY, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCSIWTHRSPY, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCGIWTHRSPY, do_wireless_ioctl)
+HANDLE_IOCTL(SIOCSIWMLME, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCGIWAPLIST, do_wireless_ioctl)
+HANDLE_IOCTL(SIOCSIWSCAN, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCGIWSCAN, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCSIWESSID, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCGIWESSID, do_wireless_ioctl)
@@ -2565,6 +2569,11 @@ HANDLE_IOCTL(SIOCSIWNICKN, do_wireless_i
 HANDLE_IOCTL(SIOCGIWNICKN, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCSIWENCODE, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCGIWENCODE, do_wireless_ioctl)
+HANDLE_IOCTL(SIOCSIWGENIE, do_wireless_ioctl)
+HANDLE_IOCTL(SIOCGIWGENIE, do_wireless_ioctl)
+HANDLE_IOCTL(SIOCSIWENCODEEXT, do_wireless_ioctl)
+HANDLE_IOCTL(SIOCGIWENCODEEXT, do_wireless_ioctl)
+HANDLE_IOCTL(SIOCSIWPMKSA, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCSIFBR, old_bridge_ioctl)
 HANDLE_IOCTL(SIOCGIFBR, old_bridge_ioctl)
 HANDLE_IOCTL(RTC_IRQP_READ32, rtc_ioctl)

