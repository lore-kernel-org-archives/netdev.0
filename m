From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Fri, 31 Jan 2014 10:37:47 -0800
Message-ID: <20140131183747.GA18262@xanatos>
References: <22081260.RNay0J72dY@athas>
 <20140129215408.GC5991@xanatos>
 <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20@AcuExch.aculab.com>
 <20140130184412.GA3787@xanatos>
 <A2CA0424C0A6F04399FB9E1CD98E03046D147453@US01WEMBX2.internal.synopsys.com>
 <52EAAF6F.7070202@pobox.com>
 <20140130214133.GB14228@xanatos>
 <52EAD038.5020409@pobox.com>
 <20140130232629.GF14228@xanatos>
 <52EB0B51.4020407@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Zimmerman <paulz@synopsys.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"renevant@internode.on.net" <renevant@internode.on.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mark Lord <mlord@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55668 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932236AbaAaSht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jan 2014 13:37:49 -0500
Content-Disposition: inline
In-Reply-To: <52EB0B51.4020407@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 09:32:49PM -0500, Mark Lord wrote:
> On 14-01-30 06:26 PM, Sarah Sharp wrote:
> > On Thu, Jan 30, 2014 at 05:20:40PM -0500, Mark Lord wrote:
> >> On 14-01-30 04:41 PM, Sarah Sharp wrote:
> >>>
> >>> Mark and David, can you pull the 3.13-td-changes-reverted branch again,
> >>> and see if the latest patch fixes your issue?  It disables scatter
> >>> gather for the ax88179_178a device, but only when it's operating at USB
> >>> 3.0 speeds.
> >>
> >> As expected, this works just fine.
> > 
> > Did it work when plugged into a USB 2.0 hub?
> 
> Curiosity, NO.  Dies almost immediately when run at USB 2.0 Hi-Speed.
> With a USB 2.0 hub, with a USB 2.0 port on a USB 3.0 hub,
> and with a USB 2.0 extension cable in place of a hub.
> 
> Near instant hangs.
> 
> Plugged directly to the USB 3.0 port, it works fine.

Ok, that makes sense.  The patch I wrote only limited scatter-gather at
USB 3.0 speeds, to see if scatter-gather could work at USB 2.0 speeds.
Reverting commit 3804fad45411b48233b48003e33a78f290d227c8 "USBNET:
ax88179_178a: enable tso if usb host supports sg dma" is the right way
to go instead.

Sarah Sharp
