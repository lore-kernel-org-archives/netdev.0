From: Chris Fries <qcf001@motorola.com>
Subject: [PATCH] usb: usbnet: suspend count gets lost when -EBUSY
Date: Tue, 5 Jul 2011 20:35:05 -0500
Message-ID: <CADuEq9BQX2BFBY3pF=CEEymfK4JPwMP7By+JZFdaLqxs+GhtJQ@mail.gmail.com>
Reply-To: C.Fries@Motorola.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og105.obsmtp.com ([64.18.0.180]:37729 "EHLO
	exprod5og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224Ab1GFBfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 21:35:30 -0400
Received: from DE01MGRG01.AM.MOT-MOBILITY.COM ([10.22.94.168])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p661a6Os019830
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 21:36:07 -0400 (EDT)
Received: from mail-pz0-f42.google.com (mail-pz0-f42.google.com [209.85.210.42])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p661a5Mv019817
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 21:36:06 -0400 (EDT)
Received: by pzk37 with SMTP id 37so3239519pzk.15
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 18:35:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When suspend is refused due to pending transmits, the
busy counter gets out of sync, and suspend will stop
working correctly.

Signed-off-by: Chris Fries <C.Fries@motorola.com>
---
 drivers/net/usb/usbnet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index cc95aad..9bcc3e3 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1451,6 +1451,7 @@ int usbnet_suspend (struct usb_interface *intf,
pm_message_t message)
 		/* don't autosuspend while transmitting */
 		if (dev->txq.qlen && (message.event & PM_EVENT_AUTO)) {
 			spin_unlock_irq(&dev->txq.lock);
+			dev->suspend_count--;
 			return -EBUSY;
 		} else {
 			set_bit(EVENT_DEV_ASLEEP, &dev->flags);
-- 
1.7.0.4
