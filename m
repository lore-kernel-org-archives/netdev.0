From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH] SIW: iWARP Protocol headers
Date: Thu, 7 Oct 2010 16:55:03 +0200
Message-ID: <OF471D7C3A.9D0876D0-ONC12577B5.004CACAE-C12577B5.0051F207@ch.ibm.com>
References: <1286393504.26136.31.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Dillow <dave-i1Mk8JYDVaaSihdK6806/g@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1286393504.26136.31.camel-FqX9LgGZnHWDB2HL1qBt2PIbXMQ5te18@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



David Dillow <dave-i1Mk8JYDVaaSihdK6806/g@public.gmane.org> wrote on 10/06/2010 09:31:44 PM:

> On Wed, 2010-10-06 at 12:37 -0600, Jason Gunthorpe wrote:
> > On Wed, Oct 06, 2010 at 02:22:55PM -0400, David Dillow wrote:
> > > On Wed, 2010-10-06 at 11:25 -0600, Jason Gunthorpe wrote:
> > > > On Wed, Oct 06, 2010 at 02:52:46PM +0200, Bernard Metzler wrote:
> > > > It is actually a little more complicated than just this. I assume
you
> > > > are casting the structures over packet payloads? In this case you
> > > > have to guarentee alignment (or used packed everywhere). Does iwarp
> > > > have provisions for alignment? If so you can construct your
bitfields
> > > > using the alignment type, ie if iWarp guarantees 4 bytes then the
> > > > biggest type you can use is u32 - then you can avoid using packed.
> > > >
> > > > Mind you, I'm not sure how to guarentee alignment when you consider
> > > > all the possible sources of unalignment in the stack: TCP, IP,L2
stack ?
> > >
> > > You don't have to. The TCP stack, IIRC, requires the architecture to
fix
> > > up misaligned accesses, or at least it used to. It will try to keep
> > > things aligned if possible -- see the comment above NET_IP_ALIGN in
> > > include/linux/skbuff.h.
> >
> > I was under the impression that this was just to align the IP
> > header.
>
> It is, and it assumes an ethernet header of 14 bytes. As you note, VLANs
> and everything else can mess with that, which is why the TCP stack
> requires the architecture to handle unaligned accesses. It's a bonus if
> iWarp can guarantee an alignment WRT the IP or TCP header, but not
> required.
>
> > > The structures in Bernard's header have all fields naturally
> > > aligned, so no need for the packed attribute and its baggage.
> >
> > No, they arent:
> >
> > > +struct iwarp_rdma_write {
> > > +   struct iwarp_ctrl   ctrl;
> > > +   __u32         sink_stag;
> > > +   __u64         sink_to;
> > > +} __attribute__((__packed__));
> >
> > For instance has sink_to unaligned if the maximum aligment of the
> > payload is only guarenteed to be 4. The proper thing to do in this
> > case is probably __attribute__((__packed__, __aligned__(4))) if that
> > works the way I think.. :)
>
> struct iwarp_ctrl consists of 2 u16s, so sink_stag is aligned to 4 bytes
> from the start of the struct iwarp_rdma_write, and sink_to is at 8 bytes
> -- so they are naturally aligned with respect to the structure. The
> compiler will not add padding, so no need for the packed attribute.
>
> Note I'm not talking about alignment in memory -- that'll depend on
> where the data starts, and as I mentioned, the stack doesn't make any
> guarantees about that, relying on the architecture to fixup any
> misaligned accesses.

agreed. all n-bytes are starting on a multipe of n-byte offset
relative to the start of the structure.

many thanks,
bernard.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
