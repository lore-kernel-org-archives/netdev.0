From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Wed, 29 Jan 2014 13:18:17 -0800
Message-ID: <20140129211817.GA5991@xanatos>
References: <20140128203007.GA3311@xanatos>
 <52E883FB.7010704@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>
To: Mark Lord <mlord@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51564 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851AbaA2VSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 16:18:20 -0500
Content-Disposition: inline
In-Reply-To: <52E883FB.7010704@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 28, 2014 at 11:30:51PM -0500, Mark Lord wrote:
> On 14-01-28 03:30 PM, Sarah Sharp wrote:
> ..
> > Can you please pull this branch, which contains a 3.13 kernel with
> > David's patch reverted, and test whether your USB ethernet device works
> > or fails?
> 
> Fails.  dmesg log attached.

It's funny, because there's certainly data transferred over endpoint
0x82, even though there were link TRBs in the middle of transfers.  Did
the "untransferred" messages stop when the device stopped working, or
did they continue?

> All I do is something akin to this:
> 
>    mount /server/ /x
>    mount --bind / /t
>    mirrordir -v --strict-mtimes /t /x/backups/empress
> 
> "mirrordir" is similar to "rsync", but less cryptic.
> The sequence above maintains a clone of the root filesystem
> of my ultrabook ("empress") on an NFS server over GigE.

Please send me the output of `sudo lsusb -t`  and `sudo lsusb -v` with
the USB device attached.  I'd like to know whether you and David have
the same device and driver.  Perhaps the link TRB issue only impacts
that device, and we can limit scatter-gather under xHCI for that device.
If not, we'll have to look at bigger fixes.

Sarah Sharp
