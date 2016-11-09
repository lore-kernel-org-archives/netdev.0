From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe
 function
Date: Wed, 09 Nov 2016 12:58:55 +0100
Message-ID: <1478692735.2428.10.camel@suse.com>
References: <Pine.LNX.4.44L0.1611081339060.1499-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, Kai-Heng Feng <kai.heng.feng@canonical.com>,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43392 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751454AbcKIMEp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 07:04:45 -0500
In-Reply-To: <Pine.LNX.4.44L0.1611081339060.1499-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-08 at 13:44 -0500, Alan Stern wrote:

> These problems could very well be caused by running at SuperSpeed
> (USB-3) instead of high speed (USB-2).
> 
> Is there any way to test what happens when the device is attached to 
> the computer by a USB-2 cable?  That would prevent it from operating at 
> SuperSpeed.
> 
> The main point, however, is that the proposed patch doesn't seem to
> address the true problem, which is that the device gets suspended
> between probes.  The patch only tries to prevent it from being
> suspended during a probe -- which is already prevented by the USB core.

But why doesn't it fail during normal operation?

I suspect that its firmware requires the altsetting

        /* should we change control altsetting on a NCM/MBIM function? */
        if (cdc_ncm_select_altsetting(intf) == CDC_NCM_COMM_ALTSETTING_MBIM) {
                data_altsetting = CDC_NCM_DATA_ALTSETTING_MBIM;
                ret = cdc_mbim_set_ctrlalt(dev, intf, CDC_NCM_COMM_ALTSETTING_MBIM);

to be set before it accepts a suspension.

	Regards
		Oliver
