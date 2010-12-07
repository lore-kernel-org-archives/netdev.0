From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: Fwd: usbnet: Recursive Locking bug ?
Date: Tue, 7 Dec 2010 11:46:32 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1012071141520.1802-100000@iolanthe.rowland.org>
References: <AANLkTi=VB0Kt=2c1C1b-Ps8x_zA5Tnf+tfHjvO8gWgm8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, <linux-usb@vger.kernel.org>
To: Neil Jones <neiljay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:45022 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752629Ab0LGQqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 11:46:33 -0500
In-Reply-To: <AANLkTi=VB0Kt=2c1C1b-Ps8x_zA5Tnf+tfHjvO8gWgm8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Dec 2010, Neil Jones wrote:

> > But what makes sure that the URB unlinked in unlink_urbs() stays a valid pointer?
> > The bottom half may run and free the URB.
> 
> I think it may be safe to remove the lock as we are walking a list of
> SKBs not URBs,
> the BH can remove SKB's from the list but we are doing a safe list walk.
> + the BH takse the list lock when it does the remove.
> 
> I could be wrong though?

A simple answer to Oliver's question is to take a reference to the 
URB while still holding the lock, then release the lock before calling 
usb_unlink_urb(), then drop the reference to the URB.

Of course, this also requires you to restart the loop from the
beginning after each unlink, and it means you need to have a way to
recognize when an URB has already been unlinked.

Alan Stern


