From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] net: qmi_wwan: Add USB IDs for MDM6600 modem on Motorola
 Droid 4
Date: Sun, 19 Mar 2017 10:10:21 -0700
Message-ID: <20170319171021.GC20572@atomide.com>
References: <20170319161957.6625-1-tony@atomide.com>
 <87lgs15iun.fsf@miraculix.mork.no>
 <20170319170254.GB20572@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, Marcel Partap <mpartap@gmx.net>,
        Michael Scott <michael.scott@linaro.org>
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:40536 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752253AbdCSRKg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Mar 2017 13:10:36 -0400
Content-Disposition: inline
In-Reply-To: <20170319170254.GB20572@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Tony Lindgren <tony@atomide.com> [170319 10:05]:
> * Bjørn Mork <bjorn@mork.no> [170319 09:33]:
> > This is a bit unusual, so I'd like to verify that it is correct.  Do you
> > happen to have a "lsusb -v" or /sys/kernel/debug/usb/devices dump for
> > this device?  Is this usage of vendor + class consistent with the
> > Windows driver *.inf data?  Are you sure that the ff/fb/ff class is only
> > used for QMI functions by this vendor ID? 
> 
> Well this is based on what the earlier Motorola mapphone v3.8 kernel has
> for in drivers/net/usb/qcusbnet/qcusbnet.c driver:
> 
> +       { /* Motorola Xoom */
> +       USB_DEVICE_AND_INTERFACE_INFO(0x22B8, 0x2A70, 0xff, 0xfb, 0xff),
> +       .driver_info = (unsigned long)&xoom_qc_netinfo
> +       },
> +       { /* MDM9600 */
> +       USB_DEVICE_AND_INTERFACE_INFO(0x22B8, 0x2E0A, 0xff, 0xfb, 0xff),
> +       .driver_info = (unsigned long)&mdm9600_qc_netinfo
> +       },
> 
> Where the "Motorola Xoom" id is also used for all mapphone devices
> with MDM6600 variants.
> 
> Then xoom_qc_netinfo in the mapphone kernel has:
> 
> +static const struct driver_info xoom_qc_netinfo = {
> +       .description   = "Xoom QCUSBNet Ethernet Device",
> +       .flags         = FLAG_ETHER|FLAG_SEND_ZLP,
> +       .bind          = xoom_qcnet_bind,
> +       .unbind        = qcnet_unbind,
> +       .data          = 0,
> +       .manage_power  = qcnet_manage_power,
> +};
> 
> And the v3.8 kernel also has drivers/usb/serial/mdm6600.c:
> 
> +static const struct usb_device_id mdm6600_id_table[] = {
> +       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2a70, 0xff, 0xff, 0xff) },
> +        /* MDM9600 */
> +       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2e0a, 0xff, 0xff, 0xff) },
> +       { USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x900e, 0xff, 0xff, 0xff) },
> +       { },
> +};
> 
> And then in drivers/usb/serial/moto_flashqsc.c:
> 
> +static struct usb_device_id id_table[] = {
> +       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2a63, 0x0a, 0, 0)},
> +       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x4281, 0x0a, 0, 0xfc)},
> +       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2db4, 0x0a, 0, 0xfc)},
> +       {USB_DEVICE(0x22b8, 0x4260)},
> +       {USB_DEVICE(0x22b8, 0x426D)},
> +       {},
> +};
> 
> Where the 0x4260 and 0x426d seem to be for the flash mode of the
> Wrigley3GLTE modem.

Oh found one more entry grepping the old patch, this time in
drivers/usb/serial/qsc6085_modem.c:

+static struct usb_device_id id_table[] = {
+       {USB_DEVICE(0x22b8, 0x2a6e)},   /* Sholes CDMA BP modem */
+       {USB_DEVICE(0x22b8, 0x2a6f)},   /* Sholes CDMA BP modem */
+       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2a70, 0xff, 0xff, 0xff)},
+       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x2e0a, 0xff, 0xff, 0xff)}, /* MDM9600 */
+       {USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x900e, 0xff, 0xff, 0xff)},
+       {},
+};

Regards,

Tony
