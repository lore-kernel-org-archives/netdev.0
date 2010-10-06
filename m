From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH] SIW: iWARP Protocol headers
Date: Wed, 6 Oct 2010 14:52:46 +0200
Message-ID: <OFC70D3F8A.C5D69C2F-ONC12577B4.0044CFB7-C12577B4.0046C012@ch.ibm.com>
References: <AANLkTimkJHntzqL5fs+6kTTq-3kzwmoDtWyVq=qGe6vj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTimkJHntzqL5fs+6kTTq-3kzwmoDtWyVq=qGe6vj-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org wrote on 10/05/2010 06:10:45 PM:

> On Tue, Oct 5, 2010 at 8:53 AM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
wrote:
> > +} __attribute__((__packed__));
>
> Apparently you make extensive use of the packed attribute. Please read
> this blog entry, in which it is explained why this is harmful:
>
> http://digitalvampire.org/blog/index.php/2006/07/31/why-you-
> shouldnt-use-__attribute__packed/
>
right, thanks, i was not aware of that
big overhead.
but...there are reasons why we may need it _packed_:
(1) to get the size of the packet hdr
(2) to read/write the hdr content

(1) is not harmful. (2) could be limited to
just one read/write operation per rx/tx path
and all other access could be done on a
structure which contains the host representation
of the hdr content. both structures could coexist
in a union, part of the rx or tx context.
would that satisfy your complain?

many thanks,
bernard.


> Bart.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
