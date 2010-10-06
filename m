From: David Dillow <dave-i1Mk8JYDVaaSihdK6806/g@public.gmane.org>
Subject: Re: [PATCH] SIW: iWARP Protocol headers
Date: Wed, 06 Oct 2010 14:22:55 -0400
Message-ID: <1286389375.26136.24.camel@lap75545.ornl.gov>
References: <AANLkTimkJHntzqL5fs+6kTTq-3kzwmoDtWyVq=qGe6vj@mail.gmail.com>
 <OFC70D3F8A.C5D69C2F-ONC12577B4.0044CFB7-C12577B4.0046C012@ch.ibm.com>
 <20101006172518.GI24268@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20101006172518.GI24268-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-10-06 at 11:25 -0600, Jason Gunthorpe wrote:
> On Wed, Oct 06, 2010 at 02:52:46PM +0200, Bernard Metzler wrote:
> It is actually a little more complicated than just this. I assume you
> are casting the structures over packet payloads? In this case you
> have to guarentee alignment (or used packed everywhere). Does iwarp
> have provisions for alignment? If so you can construct your bitfields
> using the alignment type, ie if iWarp guarantees 4 bytes then the
> biggest type you can use is u32 - then you can avoid using packed.
> 
> Mind you, I'm not sure how to guarentee alignment when you consider
> all the possible sources of unalignment in the stack: TCP, IP, L2 stack ?

You don't have to. The TCP stack, IIRC, requires the architecture to fix
up misaligned accesses, or at least it used to. It will try to keep
things aligned if possible -- see the comment above NET_IP_ALIGN in
include/linux/skbuff.h.

The structures in Bernard's header have all fields naturally aligned, so
no need for the packed attribute and its baggage.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
