From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [RFT 1/2] xhci 1.0: Limit arbitrarily-aligned scatter gather.
Date: Wed, 5 Feb 2014 16:23:50 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1402051619240.1312-100000@iolanthe.rowland.org>
References: <20140205210847.GD12087@xanatos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Laight <David.Laight@ACULAB.COM>,
	Mark Lord <mlord@pobox.com>, netdev <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Freddy Xin <freddy@asix.com.tw>,
	Ming Lei <ming.lei@canonical.com>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:46110 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754207AbaBEVXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 16:23:52 -0500
In-Reply-To: <20140205210847.GD12087@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Feb 2014, Sarah Sharp wrote:

> On Wed, Feb 05, 2014 at 11:58:12AM +0000, David Laight wrote:

> > The problem is that the ax88179_178a driver submits receive URBs that
> > cross 64k boundaries, and are not aligned (they start at an 0x40 boundary).
> > Receive USB frames can contain multiple ethernet frames, by default they
> > are 20kB (and sit in 24kB of memory).
> 
> Perhaps you should add printks when a TRB is split on 64KB boundaries
> and see if the device drops packets around that time?

This seems kind of puzzling.

In theory, any URB that's more than 1 byte long can cross a 64-KB 
boundary.  I don't understand why this should cause problems for 
xhci-hcd.  Sure, the transfer has to be split into multiple TDs where 
the boundary crossing occurs.  But why would that be problematic?

Alan Stern
