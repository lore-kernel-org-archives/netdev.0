From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe
 function
Date: Tue, 8 Nov 2016 10:25:26 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1611081020550.1499-100000@iolanthe.rowland.org>
References: <CAAd53p5=xLJR=cLwLstjmgdEg_Nr2JHUWDFa218Dhn50F_NH8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Neukum <oneukum@suse.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>
To: Kai-Heng Feng <kai.heng.feng@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:33018 "HELO
        iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1753282AbcKHPZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 10:25:28 -0500
In-Reply-To: <CAAd53p5=xLJR=cLwLstjmgdEg_Nr2JHUWDFa218Dhn50F_NH8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Nov 2016, Kai-Heng Feng wrote:

> Hi,
> 
> On Mon, Nov 7, 2016 at 7:02 PM, Oliver Neukum <oneukum@suse.com> wrote:
> > On Fri, 2016-11-04 at 17:57 +0800, Kai-Heng Feng wrote:
> >> Sometimes cdc_mbim failed to probe if runtime pm is enabled:
> >> [    9.305626] cdc_mbim: probe of 2-2:1.12 failed with error -22
> >>
> >> This can be solved by increase its pm usage counter.
> >>
> >> Signed-off-by: Kai-Heng Feng <kai.heng.feng@canonical.com>
> >
> > For the record:
> >
> > NAK. This fixes a symptom. If this patch helps something is broken in
> > device core. We need to find that.
> >
> 
> Please check attached dmesg with usbcore.dyndbg="+p".

The log shows that the device went into suspend _before_ the cdc_mbim 
driver was probed, not during the probe.  Then just before the probe 
was started, the USB core tried to resume the device and the resume 
failed.

The log shows a bunch of other problems with this device:

[    3.862253] usb 2-2: config 1 has an invalid interface number: 12 but max is 1
[    3.862254] usb 2-2: config 1 has an invalid interface number: 13 but max is 1
[    3.862254] usb 2-2: config 1 has an invalid interface number: 13 but max is 1
[    3.862255] usb 2-2: config 1 has no interface number 0
[    3.862256] usb 2-2: config 1 has no interface number 1
...
[    8.295180] usb 2-2: Disable of device-initiated U1 failed.
[    8.295322] usb 2-2: Disable of device-initiated U2 failed.

I get the impression that the device won't work properly with runtime 
PM at all.

Alan Stern
