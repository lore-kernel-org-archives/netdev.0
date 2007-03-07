From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Tue, 6 Mar 2007 18:03:10 -0800
Message-ID: <20070307020310.GA20466@bougret.hpl.hp.com>
References: <1173144447.15891.93.camel@johannes.berg> <20070306171316.GA19669@bougret.hpl.hp.com> <200703061943.07350.mb@bu3sch.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Dan Williams <dcbw@redhat.com>,
	Jouni Malinen <jkm@devicescape.com>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:59328 "EHLO
	gundega.hpl.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161211AbXCGCDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 21:03:45 -0500
Content-Disposition: inline
In-Reply-To: <200703061943.07350.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 07:43:06PM +0100, Michael Buesch wrote:
> 
> Ok, it is wrapping the following ioctls:
> 
> HANDLE_IOCTL(SIOCGIWRANGE, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWSPY, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWSPY, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWTHRSPY, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWTHRSPY, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWAPLIST, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWSCAN, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWESSID, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWESSID, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWNICKN, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWNICKN, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCSIWENCODE, do_wireless_ioctl)
> HANDLE_IOCTL(SIOCGIWENCODE, do_wireless_ioctl)
> 
> What about SIOCSIWSCAN, SIOCSIWENCODEEXT, SIOCGIWENCODEEXT
> and some others that also use iw_point?

	Ok, please check the patch attached. I don't have a box to
test that on, and on my 32 bit kernel it is not even compiled, but I
believe I got everything all right.
	Please push that to the usual channels...

> Greetings Michael.

	Thanks again,

	Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

------------------------------------------------------------------

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
