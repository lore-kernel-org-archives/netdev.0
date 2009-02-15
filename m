From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: [PATCH] b44: Disable device on shutdown (Resend)
Date: Sun, 15 Feb 2009 16:03:29 +0200
Message-ID: <1295ed070902150603u784fe48dg47719647cd8cafed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:52083 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbZBOODb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 09:03:31 -0500
Received: by fg-out-1718.google.com with SMTP id 16so122551fgg.17
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2009 06:03:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

There's been about 3 months since the last time this patch was sent,
so I assume it was lost in the
queue or something.

Please consider applying. It is only a one-liner, It fixes a real WTF-type bug
(modprobe -r b44 && modprobe b44 and boom! no internet!)
and I 've been testing, using and carrying it along for the last 3 months
(not to mention having to spend the time to debug it in the first place :-)

It is a regression from 2.6.24 IIRC (when b44 was ported to the ssb
stack) and the patch is
authored by the guy who wrote this port.

Currently this and the other b44 patch I 'm going to resend next are
the only things that make
me maintain a custom kernel.

Thanks in advance,
Pantelis

---------- Forwarded message ----------
From: Michael Buesch <mb@bu3sch.de>
Date: Sun, Nov 16, 2008 at 4:39 PM
Subject: [PATCH] b44: Disable device on shutdown
To: Jeff Garzik <jeff@garzik.org>
Cc: netdev@vger.kernel.org, Pantelis Koukousoulas <pktoss@gmail.com>,
Gary Zambrano <zambrano@broadcom.com>, stable@kernel.org


Disable the SSB core on device shutdown.
This has two advantages:
1) A clean device shutdown is always desired here, because we disable
  the device's global crystal in the next statement.
2) This fixes a bug where the device will come up with the enable-bit
  set on the next initialization (without a reboot inbetween).
  This causes breakage on the second initialization due to code that
  checks this bit (ssb_device_is_enabled() checks).

Reported-by: Pantelis Koukousoulas <pktoss@gmail.com>
Signed-off-by: Michael Buesch <mb@bu3sch.de>
Cc: stable@kernel.org

---

I think this should go in for 2.6.28, as it fixes a
device-doesn't-work-anymore bug after a insmod-rmmod-insmod cycle.

Index: wireless-testing/drivers/net/b44.c
===================================================================
--- wireless-testing.orig/drivers/net/b44.c     2008-11-16
14:45:08.000000000 +0100
+++ wireless-testing/drivers/net/b44.c  2008-11-16 14:47:06.000000000 +0100
@@ -2233,6 +2233,7 @@ static void __devexit b44_remove_one(str
       struct net_device *dev = ssb_get_drvdata(sdev);

       unregister_netdev(dev);
+       ssb_device_disable(sdev, 0);
       ssb_bus_may_powerdown(sdev->bus);
       free_netdev(dev);
       ssb_pcihost_set_power_state(sdev, PCI_D3hot);

--
Greetings Michael.
