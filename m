From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH v2 0/8] NFC: fix device allocation and nfcmrvl crashes
Date: Tue, 18 Apr 2017 12:09:16 +0200
Message-ID: <20170418100916.GB2823@localhost>
References: <20170330101542.15384-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Lauro Ramos Venancio <lauro.venancio@openbossa.org>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35031 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755066AbdDRKJU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 06:09:20 -0400
Content-Disposition: inline
In-Reply-To: <20170330101542.15384-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 30, 2017 at 12:15:34PM +0200, Johan Hovold wrote:
> This started out with the observation that the nfcmrvl_uart driver
> unconditionally dereferenced the tty class device despite the fact that
> not every tty has an associated struct device (Unix98 ptys). Some
> further changes were needed in the common nfcmrvl code to fully address
> this, some of which also incidentally fixed a few related bugs (e.g.
> resource leaks in error paths).
> 
> While fixing this I stumbled over a regression in NFC core that lead to
> broken registration error paths and misnamed workqueues.
> 
> Note that this has only been tested by configuring the n_hci line
> discipline for different ttys without any actual NFC hardware connected.

> Johan Hovold (8):
>   NFC: fix broken device allocation
>   NFC: nfcmrvl_uart: add missing tty-device sanity check
>   NFC: nfcmrvl: do not use device-managed resources
>   NFC: nfcmrvl: use nfc-device for firmware download
>   NFC: nfcmrvl: fix firmware-management initialisation
>   NFC: nfcmrvl_uart: fix device-node leak during probe
>   NFC: nfcmrvl_usb: use interface as phy device
>   NFC: nfcmrvl: allow gpio 0 for reset signalling

Any chance of getting these into 4.12, Samuel?

Note that patches 2 and 4 fixes NULL-derefs that can be triggered by an
unprivileged user.

Thanks,
Johan
