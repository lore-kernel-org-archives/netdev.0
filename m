From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: Active URB submitted twice in pegasus driver
Date: Tue, 26 Mar 2013 11:52:18 -0700
Message-ID: <20130326185218.GD10317@xanatos>
References: <20130325223834.GF6869@xanatos>
 <alpine.DEB.2.02.1303261655450.3724@fry.nucleusys.com>
 <20130326170140.GC10317@xanatos>
 <alpine.DEB.2.02.1303261909260.4226@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45626 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760102Ab3CZSwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 14:52:19 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1303261909260.4226@fry.nucleusys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 07:28:53PM +0200, Petko Manolov wrote:
> On Tue, 26 Mar 2013, Sarah Sharp wrote:
> 
> >On Tue, Mar 26, 2013 at 05:22:07PM +0200, Petko Manolov wrote:
> >>On Mon, 25 Mar 2013, Sarah Sharp wrote:
> >After taking a brief glance at the pegasus code,
> >pegasus_set_multicast looks broken.  It sets the control URB
> >status to zero and calls ctrl_callback(), which does some stuff if
> >the URB status is zero.  It doesn't look like
> >pegasus_set_multicast() is an URB callback function, so why in the
> >world is it touching a control URB that could possibly be in
> >flight else where?
> 
> Beats me, i've got nothing to do with this driver. :-P
> 
> Anyway, playing with the URB status looks rather stupid and is
> definitely a bug.  I'll make a patch that fixes the problem.
> 
> >It looks like the control URB is used to do things like get or set
> >registers, so what's stopping the upper layers from calling get
> >registers (which will submit the control URB and schedule a wait
> >queue), and then pegasus_set_multicast(), which will go overwrite
> >the active URB status?  USB device drivers should not be writing
> >or reading fields in a submitted URB until the completion
> >handler's callback function is called.
> 
> Err, see my previous comment.  It can't be me.  Maybe i've been too
> drunk. Or stupid.  Or both... :-)

Nah, everybody makes silly coding mistakes.  I was just trying to
clarify, since I don't know the driver.  Send me a patch and I'll see if
it fixes the warning.

But considering the multicast code is pretty old, I bet I'm running into
a different bug...

Sarah Sharp
