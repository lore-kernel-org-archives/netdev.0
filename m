From: Greg KH <gregkh@suse.de>
Subject: Re: [BUG] skge 0000:02:05: read data parity error
Date: Mon, 14 Jan 2008 13:30:54 -0800
Message-ID: <20080114213054.GA3573@suse.de>
References: <6101e8c40801141157j1ce7d3f0if2e4eb2344b6c844@mail.gmail.com> <20080114125200.28cb4c69@deepthought> <20080114210105.GG9847@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"Oliver Pinter (Pint??r Oliv??r)" <oliver.pntr@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48990 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbYANVa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 16:30:28 -0500
Content-Disposition: inline
In-Reply-To: <20080114210105.GG9847@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 14, 2008 at 11:01:05PM +0200, Adrian Bunk wrote:
> On Mon, Jan 14, 2008 at 12:52:00PM -0800, Stephen Hemminger wrote:
> > On Mon, 14 Jan 2008 20:57:49 +0100
> > "Oliver Pinter (Pint??r Oliv??r)" <oliver.pntr@gmail.com> wrote:
> > 
> > > Hi All!
> > > 
> > > It is fully reproductable under 2.6.22.15, 2.6.23.13 (all tainted and
> > > not tainted [4 different kernel] ) and 2 different PC:
> > > 
> > > [BUG] skge 0000:02:05: read data parity error
> > > [BUG] skge 0000:02:05: read data parity error
> > > 
> > > steps:
> > > 1. login as root
> > > 2. start mc
> > > 3. cd /sys/bus/pci/drivers/skge/0000:02:05.0
> > > 4. press F3 (mcview) on resource0
> > > 5. the system hang up, without panic or bug ... only this message
> > > printed 2x: [BUG] skge 0000:02:05: read data parity error
> > 
> > This is not a bug.
> > 
> > The hardware has some debug registers that if accessed cause a read
> > back to the host. Since this can point anywhere, it will cause errors
> > or system hang.
> > 
> > The point is don't do it.
> 
> Is it really a good idea that _reading_ files under /sys can kill your 
> machine?

No, but mmapping them as root and then doing bad things with that data
isn't recommended :)

Note that this is a special file, just like the ones in /proc, that
provide a mmap interface into the pci card's resource.  This is nothing
new...

thanks,

greg k-h
