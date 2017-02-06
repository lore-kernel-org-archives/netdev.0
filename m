From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH net 1/4] pegasus: Use heap buffers for all register access
Date: Mon, 6 Feb 2017 09:28:22 +0100
Message-ID: <20170206082822.GA23451@kroah.com>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165603.GV3442@decadent.org.uk>
 <20170205003038.GB21184@kroah.com>
 <20170206081444.smcgjkmdepxoosb6@p310>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org,
        Lisandro =?iso-8859-1?Q?Dami=E1n_Nicanor_P=E9rez?= Meyer
        <lisandro@debian.org>
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38398 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750909AbdBFI33 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 03:29:29 -0500
Content-Disposition: inline
In-Reply-To: <20170206081444.smcgjkmdepxoosb6@p310>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2017 at 10:14:44AM +0200, Petko Manolov wrote:
> On 17-02-05 01:30:39, Greg KH wrote:
> > On Sat, Feb 04, 2017 at 04:56:03PM +0000, Ben Hutchings wrote:
> > > Allocating USB buffers on the stack is not portable, and no longer
> > > works on x86_64 (with VMAP_STACK enabled as per default).
> > 
> > It's never worked on other platforms, so these should go to the stable 
> > releases please.
> 
> As far as i know both drivers works fine on other platforms, though I only 
> tested it on arm and mipsel. ;)

It all depends on the arm and mips platforms, the ones that can not DMA
from stack memory are the ones that would always fail here (since the
2.2 kernel days).

> Random thought: isn't it better to add the alloc/free code in usb_control_msg() 
> and avoid code duplication all over the driver space?

A very long time ago we considered it, but realized that the majority of
drivers already had the memory dynamically allocated, so we just went
with this.  Perhaps we could revisit that if it turns out we were wrong,
and would simplify things.

thanks,

greg k-h
