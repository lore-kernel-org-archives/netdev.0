From: Sebastien Dugue <sebastien.dugue@bull.net>
Subject: Re: [PATCH HACK] powerpc: quick hack to get a functional eHEA with
 hardirq preemption
Date: Tue, 16 Sep 2008 14:22:37 +0200
Message-ID: <20080916142237.0dc5d024@bull.net>
References: <20080915100406.342e027a@bull.net>
	<48CE5684.4000506@de.ibm.com>
	<20080915151332.6a3a7c80@bull.net>
	<20080916115947.GA6995@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <osstklei@de.ibm.com>, tklein@de.ibm.com,
	tinytim@us.ibm.com, Linux-rt <linux-rt-users@vger.kernel.org>,
	themann@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	jean-pierre.dion@bull.net, linux-ppc <linuxppc-dev@ozlabs.org>,
	raisch@de.ibm.com, gilles.carry@ext.bull.net
To: avorontsov@ru.mvista.com
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20080916115947.GA6995@oksana.dev.rtsoft.ru>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi Anton,

On Tue, 16 Sep 2008 15:59:47 +0400 Anton Vorontsov <avorontsov@ru.mvista.com> wrote:

> On Mon, Sep 15, 2008 at 03:13:32PM +0200, Sebastien Dugue wrote:
> [...]
> > > we are a bit worried about putting this into the mainstream part of non real
> > > time linux.
> > 
> >   Heck, I sure do not want this to be applied mainstream nor into any tree.
> > The sole purpose of this patch was to trigger some reaction from the people who
> > know the hardware and try to understand where the problem lies.
> > 
> > > There interrupts work perfectly fine, and it was a bit of a
> > > challenge to get there for all cases / configurations / machines.
> > 
> >   Agreed, but the fact that it fails with hardirq preemption leads me to
> > believe (without any more knowledge about the harware) that there might be
> > something amiss with this driver (or the code concerning the XICS)
> > nevertheless.
> > 
> > > 
> > > Could you try to enable these changes only for RT-Linux via a real-time
> > > kconfig switch?
> > 
> >   Nope, this is just a quick hack that allows me to have a functional eHEA under
> > the rt kernel. I want to understand what the problem is:
> > 
> >   - Is the eHEA really delivering level interrupts to the XICS?
> > 
> >   - Is the XICS loosing interrupts when they are masked?
> 
> There is a known bug in the -rt kernels, the bug causes handlers
> to lose edge interrupts.
> 
> See this patch:
> 
> http://lkml.org/lkml/2008/6/30/372

  Yes, I've been following that thread back then and my hack is based on your
patch. So yes, it seems to be the same problem and it lies in the way -rt handles
the fasteoi flow.

  But looking at the comments from the XICS code, it seems that its wired for
level only interrupts. Therefore without any more specs, it's still not clear to
me that there's not a bug with the way the xics handles eHEA interrupts.

  Are the eHEA interrupts really level interrupts? If so why do they get lost
when masked?

  I just found that not masking that particular interrupt in the fasteoi path
makes the thing work!

  Thanks,

  Sebastien.

> 
> >   - ...?
> 
> -- 
> Anton Vorontsov
> email: cbouatmailru@gmail.com
> irc://irc.freenode.net/bd2
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rt-users" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
