From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [RFT 1/2] xhci 1.0: Limit arbitrarily-aligned scatter gather.
Date: Wed, 5 Feb 2014 13:45:07 -0800
Message-ID: <20140205214507.GF12087@xanatos>
References: <20140205210847.GD12087@xanatos>
 <Pine.LNX.4.44L0.1402051619240.1312-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	Mark Lord <mlord@pobox.com>, netdev <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Freddy Xin <freddy@asix.com.tw>,
	Ming Lei <ming.lei@canonical.com>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63291 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753750AbaBEVpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Feb 2014 16:45:10 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1402051619240.1312-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 05, 2014 at 04:23:50PM -0500, Alan Stern wrote:
> On Wed, 5 Feb 2014, Sarah Sharp wrote:
> 
> > On Wed, Feb 05, 2014 at 11:58:12AM +0000, David Laight wrote:
> 
> > > The problem is that the ax88179_178a driver submits receive URBs that
> > > cross 64k boundaries, and are not aligned (they start at an 0x40 boundary).
> > > Receive USB frames can contain multiple ethernet frames, by default they
> > > are 20kB (and sit in 24kB of memory).
> > 
> > Perhaps you should add printks when a TRB is split on 64KB boundaries
> > and see if the device drops packets around that time?
> 
> This seems kind of puzzling.
> 
> In theory, any URB that's more than 1 byte long can cross a 64-KB 
> boundary.  I don't understand why this should cause problems for 
> xhci-hcd.  Sure, the transfer has to be split into multiple TDs where 
> the boundary crossing occurs.  But why would that be problematic?

If we split a non-scatter gather URB into two TRBs because of the 64-KB
boundary rule, and we have to put a link TRB in between them, that may
violate the TD fragments rule for 1.0 hosts.

So the debugging should really only trigger when there's a link TRB in
between two TRBs on the bulk ring.

Sarah Sharp
