From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH] SIW: iWARP Protocol headers
Date: Wed, 6 Oct 2010 11:25:18 -0600
Message-ID: <20101006172518.GI24268@obsidianresearch.com>
References: <AANLkTimkJHntzqL5fs+6kTTq-3kzwmoDtWyVq=qGe6vj@mail.gmail.com> <OFC70D3F8A.C5D69C2F-ONC12577B4.0044CFB7-C12577B4.0046C012@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <OFC70D3F8A.C5D69C2F-ONC12577B4.0044CFB7-C12577B4.0046C012-Xeyd2O9EBijQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 06, 2010 at 02:52:46PM +0200, Bernard Metzler wrote:
> 
> 
> linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org wrote on 10/05/2010 06:10:45 PM:
> 
> > On Tue, Oct 5, 2010 at 8:53 AM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
> wrote:
> > > +} __attribute__((__packed__));
> >
> > Apparently you make extensive use of the packed attribute. Please read
> > this blog entry, in which it is explained why this is harmful:
> >
> > http://digitalvampire.org/blog/index.php/2006/07/31/why-you-
> > shouldnt-use-__attribute__packed/
> >
> right, thanks, i was not aware of that
> big overhead.
> but...there are reasons why we may need it _packed_:
> (1) to get the size of the packet hdr
> (2) to read/write the hdr content

It is actually a little more complicated than just this. I assume you
are casting the structures over packet payloads? In this case you
have to guarentee alignment (or used packed everywhere). Does iwarp
have provisions for alignment? If so you can construct your bitfields
using the alignment type, ie if iWarp guarantees 4 bytes then the
biggest type you can use is u32 - then you can avoid using packed.

Mind you, I'm not sure how to guarentee alignment when you consider
all the possible sources of unalignment in the stack: TCP, IP, L2 stack ?

Otherwise you need a strategy for dealing with unaligned data for
portability. :(

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
