From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: potential overflow in de4x5.c
Date: Mon, 4 Jan 2010 00:35:14 -0700
Message-ID: <20100104073514.GA987@lackof.org>
References: <20100103101356.GA13023@bicker> <20100104072844.GB518@lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <error27@gmail.com>,
	Kyle McMartin <kyle@mcmartin.ca>, netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:56412 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145Ab0ADHfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 02:35:14 -0500
Content-Disposition: inline
In-Reply-To: <20100104072844.GB518@lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2010 at 12:28:44AM -0700, Grant Grundler wrote:
> On Sun, Jan 03, 2010 at 12:13:56PM +0200, Dan Carpenter wrote:
> > Hi I found this using smatch (http://repo.or.cz/w/smatch.git).
> > 
> > drivers/net/tulip/de4x5.c
> >   4772          lp->active = *p++;
> >   4773          if (MOTO_SROM_BUG) lp->active = 0;
> >   4774          lp->phy[lp->active].gep = (*p ? p : NULL); p += (2 * (*p) + 1);
> > 
> > lp->phy is an array of size 8.
> > 
> > MOTO_SROM_BUG is defined like this. 
> > 
> > #define MOTO_SROM_BUG    (lp->active == 8 && (get_unaligned_le32(dev->dev_addr) & 0x00ffffff) == 0x3e0008)
> > 
> > If lp->active == 8 then we have a buffer overflow.
> 
> Dan,
> When does the overflow actually occur?
> 
> That code is reseting the value to work around a specific SROM bug:
>    http://lists.ozlabs.org/pipermail/linuxppc-dev/1999-March/001421.html
> 
> If you want to make the "input validation" more robust, that would be fine with me.
> But smatch hasn't convinced me there is a bug here.

BTW, someone suggested to fix up this same bit of code before:
   http://www.mail-archive.com/netdev@vger.kernel.org/msg09838.html

And I'm not sure why that patch wasn't accepted then either. Patch looks fine to me.

thanks,
grant
