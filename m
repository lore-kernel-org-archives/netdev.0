From: "David S. Miller" <davem@davemloft.net>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 21:36:56 -0700 (PDT)
Message-ID: <20050520.213656.28396543.davem@davemloft.net>
References: <20050520194220.GA18259@havoc.gtf.org>
	<20050520.152836.48528379.davem@davemloft.net>
	<1116630261.31523.42.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1116630261.31523.42.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 20 May 2005 16:04:21 -0700

> On Fri, 2005-05-20 at 15:28 -0700, David S.Miller wrote:
> > From: Jeff Garzik <jgarzik@pobox.com>
> > Date: Fri, 20 May 2005 15:42:20 -0400
> > 
> > > 9) [additional review]  DaveM, others: is this correct for all arches?
> > > 
> > > +       if (unlikely((align = (unsigned long) skb->data & 0x7))) {
> > > +               skb_reserve(skb, 8 - align);
> > > +       }
> > 
> > It's probably not even necessary.  dev_alloc_skb() should be returning
> > an SKB with skb->data at least cache_line_size() aligned (see mm/slab.c)
> > unless the platform defines an ARCH_KMALLOC_MINALIGN override.
> 
> If I remember correctly, I was seeing some SKB with skb->data that is 4-
> byte aligned on some Fedora kernels. I don't remember which kernel. This
> device has an alignment requirement of at least 8-bytes for the receive
> buffers.

Just keep it in for now then.  I wouldn't be surprised if some 2.4.x
kernels let this happen.

> Yes, but in this case, cksum is the checksum calculated over the entire
> TCP/UDP packet including the pseudo IP header. Jeff is right, it should
> always be 0xffff when the checksum is correct. Checking for zero is a
> bug.

Ok, thanks for verifying.

> Originally, the driver pulse interval was set at 250 msec, but it's been
> extended to a few seconds. So the driver currently will write the pulse
> every second and do the serdes related checking at the same time.

I think the current timer stuff is fine, at least for now.
