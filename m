From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: [PATCH] cdc-ether: Assume link is up initially
Date: Wed, 06 Jan 2010 01:26:43 +0000
Message-ID: <1262741203.26813.58.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: speedyboyinovator-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The bug report <http://bugzilla.kernel.org/show_bug.cgi?id=14791>
implies that at least some devices will not send a Network Connection
notification if the link is initially up.  Further, the CDC-ECM
specification states that '[n]etworking devices are typically "Always
Connected", spending all of their time with the "link up"'.  So it
appears to be safer to assume the link is up and to rely on the device
to tell us otherwise.

This is a partial revert of:

commit 37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71
Author: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Date:   Wed Nov 4 15:29:52 2009 +0000

    usbnet: Set link down initially for drivers that update link state

Signed-off-by: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
---
This should be tested by someone with one of these devices, preferably
you since you reported the bug.

Ben.

 drivers/net/usb/cdc_ether.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 21e183a..4f27f02 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -419,7 +419,7 @@ static int cdc_manage_power(struct usbnet *dev, int on)
 
 static const struct driver_info	cdc_info = {
 	.description =	"CDC Ethernet Device",
-	.flags =	FLAG_ETHER | FLAG_LINK_INTR,
+	.flags =	FLAG_ETHER,
 	// .check_connect = cdc_check_connect,
 	.bind =		cdc_bind,
 	.unbind =	usbnet_cdc_unbind,
-- 
1.6.5.7
