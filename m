From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH v2 0/8] NFC: fix device allocation and nfcmrvl crashes
Date: Tue, 16 May 2017 11:42:29 +0200
Message-ID: <20170516094229.GN3657@localhost>
References: <20170330101542.15384-1-johan@kernel.org>
 <20170426224238.GB3717@zurbaran.ger.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170426224238.GB3717@zurbaran.ger.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Samuel,

On Thu, Apr 27, 2017 at 12:42:38AM +0200, Samuel Ortiz wrote:
> Hi Johan,
> 
> On Thu, Mar 30, 2017 at 12:15:34PM +0200, Johan Hovold wrote:
> > This started out with the observation that the nfcmrvl_uart driver
> > unconditionally dereferenced the tty class device despite the fact that
> > not every tty has an associated struct device (Unix98 ptys). Some
> > further changes were needed in the common nfcmrvl code to fully address
> > this, some of which also incidentally fixed a few related bugs (e.g.
> > resource leaks in error paths).
> > 
> > While fixing this I stumbled over a regression in NFC core that lead to
> > broken registration error paths and misnamed workqueues.
> > 
> > Note that this has only been tested by configuring the n_hci line
> > discipline for different ttys without any actual NFC hardware connected.
> > 
> > Johan
> > 
> > 
> > Changes in v2
> >  - fix typo in commit message (1/8)
> >  - release reset gpio in error paths (3/8)
> >  - fix description of patch impact (3/8)
> >  - allow gpio 0 to be used for reset signalling (8/8, new)
> > 
> > 
> > Johan Hovold (8):
> >   NFC: fix broken device allocation
> >   NFC: nfcmrvl_uart: add missing tty-device sanity check
> >   NFC: nfcmrvl: do not use device-managed resources
> >   NFC: nfcmrvl: use nfc-device for firmware download
> >   NFC: nfcmrvl: fix firmware-management initialisation
> >   NFC: nfcmrvl_uart: fix device-node leak during probe
> >   NFC: nfcmrvl_usb: use interface as phy device
> >   NFC: nfcmrvl: allow gpio 0 for reset signalling
> Applied, thanks.

These never made it into net-next and 4.12-rc1, so will you be sending
them on as fixes for 4.12-rc instead?

Thanks,
Johan
