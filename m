From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Wed, 26 May 2004 10:12:17 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526001217.GA2689@sgi.com>
References: <20040524072657.GC27177@sgi.com> <20040524004045.58b3eb44.davem@redhat.com> <20040524080431.GD27177@sgi.com> <20040524100634.1349295d.davem@redhat.com> <20040525010434.GA31134@sgi.com> <20040525105101.2da85469.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040525105101.2da85469.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 25, 2004 at 10:51:01AM -0700, David S. Miller wrote:
> On Tue, 25 May 2004 11:04:34 +1000
> Greg Banks <gnb@sgi.com> wrote:
> 
> > I agree that this code appears to implictly rely on always getting
> > complete send ring updates.
> 
> Greg, did you see Micahel Chan's response?  A Broadcom engineer
> is telling us "the hardware does not ACK partial TX packets."

Yes I did.  I've been working towards gathering data for a reply.

> I can't think of a more reliable source for this kind of information,
> can you?

I can think of one: actual observation of the card in action in the
field.  Experiment trumps theory.

To this end, I instrumented the driver + my patch to BUG() out if
the tx_ring_info.index is not a predicted value, i.e. if the tg3_tx()
ever starts partway through a packet.  It's been running overnight
under >200 MB/s of NFS read load, nothing yet.

> I don't argue that you aren't seeing something strange, but perhaps
> that is due to corruption occuring elsewhere, or perhaps something
> peculiar about your system hardware (perhaps the PCI controller
> mis-orders PCI transactions or something silly like that)?

There are many things peculiar about our hardware.  Otherwise we'd
be "the world stops at 4 processors" Dell.

> Have you reproduced this on some system other than these huge SGI
> ones?

I haven't tried; my job is first and foremost to make SGI hardware
work.  However I did point you to a report on lkml where someone on
non-SGI hardware has seen what appears to be the same problem.  I'm not
yet willing to consign this to the "wacky SGI PCI hardware" bucket.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
