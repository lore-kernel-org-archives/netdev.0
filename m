From: akpm@linux-foundation.org
Subject: [patch 04/18] via-rhine: disable rx_copybreak on archs that don't allow unaligned DMA access
Date: Fri, 10 Aug 2007 14:05:15 -0700
Message-ID: <200708102105.l7AL5FUp008954@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jailbird@alcatraz.fdf.net, ink@jurassic.park.msu.ru,
	romieu@fr.zoreil.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48371 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759294AbXHJVG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:06:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dustin Marquess <jailbird@alcatraz.fdf.net>

Patch to disable the rx_copybreak feature on hardware architectures that
don't allow unaligned DMA access.

#ifdef code taken from tulip_core.c.  Problem pointed out by Ivan
Kokshaysky.

Signed-off-by: Dustin Marquess <jailbird@alcatraz.fdf.net>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/via-rhine.c |    6 ++++++
 1 files changed, 6 insertions(+)

diff -puN drivers/net/via-rhine.c~via-rhine-disable-rx_copybreak-on-archs-that drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c~via-rhine-disable-rx_copybreak-on-archs-that
+++ a/drivers/net/via-rhine.c
@@ -42,7 +42,13 @@ static int max_interrupt_work = 20;
 
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1518 effectively disables this feature. */
+#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
+       || defined(CONFIG_SPARC) || defined(__ia64__) \
+       || defined(__sh__) || defined(__mips__)
+static int rx_copybreak = 1518;
+#else
 static int rx_copybreak;
+#endif
 
 /* Work-around for broken BIOSes: they are unable to get the chip back out of
    power state D3 so PXE booting fails. bootparam(7): via-rhine.avoid_D3=1 */
_
