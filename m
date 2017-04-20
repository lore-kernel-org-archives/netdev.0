From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR for Telit PID 0x1201
Date: Thu, 20 Apr 2017 11:02:08 +0200
Message-ID: <87lgqva1v3.fsf@miraculix.mork.no>
References: <1491838463-20299-1-git-send-email-dnlplm@gmail.com>
        <87efwob92t.fsf@miraculix.mork.no>
        <CAAP7ucL0KLCxVSaO4Vf0LH=T7vRCtm5R2p9VFov+5V0OJF8Xcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Daniele Palmas <dnlplm@gmail.com>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-usb@vger.kernel.org
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51397 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935613AbdDTJCY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 05:02:24 -0400
In-Reply-To: <CAAP7ucL0KLCxVSaO4Vf0LH=T7vRCtm5R2p9VFov+5V0OJF8Xcg@mail.gmail.com>
        (Aleksander Morgado's message of "Wed, 19 Apr 2017 20:32:25 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aleksander Morgado <aleksander@aleksander.es> writes:

> I'm just running --dms-get-operating-mode multiple times, and getting
> errors frequently:

Could you retry that with cdc-wdm debugging enabled (e.g.
"echo 'module cdc_wdm +fp' > /sys/kernel/debug/dynamic_debug/control")
and something like this:


diff --git a/drivers/usb/class/cdc-wdm.c b/drivers/usb/class/cdc-wdm.c
index 8fda45a45bd3..c0f25ace9fc6 100644
--- a/drivers/usb/class/cdc-wdm.c
+++ b/drivers/usb/class/cdc-wdm.c
@@ -211,6 +211,8 @@ static void wdm_in_callback(struct urb *urb)
 		}
 	}
=20
+	dev_dbg(&desc->intf->dev, "rerr=3D%d, status=3D%d, length=3D%d, resp_coun=
t=3D%d\n", desc->rerr, status, length, desc->resp_count);
+
 	/*
 	 * Handling devices with the WDM_DRAIN_ON_OPEN flag set:
 	 * If desc->resp_count is unset, then the urb was submitted
@@ -516,6 +518,9 @@ static ssize_t wdm_read
 		return -ERESTARTSYS;
=20
 	cntr =3D ACCESS_ONCE(desc->length);
+
+	dev_dbg(&desc->intf->dev, "rerr=3D%d, length=3D%d\n", desc->rerr, cntr);
+
 	if (cntr =3D=3D 0) {
 		desc->read =3D 0;
 retry:



And/or a usbmon dump?  That would be.probably show us the sequence of
events leading to this problem.

Desperately trying to figure out some other way to solve the issue that
commit  833415a3e781 ("cdc-wdm: fix "out-of-sync" due to missing
notifications") was supposed to fix....



Bj=C3=B8rn
