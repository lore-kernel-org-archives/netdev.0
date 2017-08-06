From: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Subject: Re: [PATCH v06 18/36] uapi linux/errqueue.h: include linux/time.h in
 user space
Date: Sun, 6 Aug 2017 23:56:54 +0300
Message-ID: <20170806205654.GF28459@lakka.kapsi.fi>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
 <20170806164428.2273-19-mikko.rapeli@iki.fi>
 <CAF=yD-L2ntuH54J_SwN9WcpBMgkV_v0e-Q2Pu2mrQ3+1RozGFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Soheil Hassas Yeganeh <soheil-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAF=yD-L2ntuH54J_SwN9WcpBMgkV_v0e-Q2Pu2mrQ3+1RozGFQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2017 at 04:23:16PM -0400, Willem de Bruijn wrote:
> On Sun, Aug 6, 2017 at 12:44 PM, Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org> wrote:
> > linux/time.h conflicts with user space header time.h. Try to be compatible
> > with both.
> >
> > Fixes userspace compilation error:
> >
> > error: array type has incomplete element type
> >  struct timespec ts[3];
> >
> > Signed-off-by: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
> > Cc: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> > Cc: Soheil Hassas Yeganeh <soheil-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> > Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > ---
> >  include/uapi/linux/errqueue.h | 6 ++++++
> >  1 file changed, 6 insertions(+)
> >
> > diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
> > index 07bdce1f444a..b310b2c6d94f 100644
> > --- a/include/uapi/linux/errqueue.h
> > +++ b/include/uapi/linux/errqueue.h
> > @@ -3,6 +3,12 @@
> >
> >  #include <linux/types.h>
> >
> > +#ifdef __KERNEL__
> > +#include <linux/time.h>
> > +#else
> > +#include <time.h>
> > +#endif /* __KERNEL__ */
> 
> This will break applications that include <linux/time.h> manually.
> I previously sent a patch to use libc-compat to make compilation succeed
> when both are included in the case where <linux/time.h> is included after
> <time.h>.
> 
>   https://lkml.org/lkml/2016/9/12/872
> 
> The inverse will require changes to the libc header to avoid redefining
> symbols already defined by <linux/time.h>
> 
> The second patch in that 2-patch set included <linux/time.h>
> unconditionally after the fix. This broke builds that also included
> <time.h> in the wrong order. I did not resubmit the first patch as a
> stand-alone, as it is not sufficient to avoid breakage.

I wasn't aware of your change, but I was about to send this to fix the
case when glibc <time.h> is included before <linux/time.h>:

https://github.com/mcfrisk/linux/commit/f3952a27b8a21c6478d26e6246055383483f6a66

but you also ran into problems where <linux/time.h> is included before
<time.h> which need fixes in libc header side.

So how to proceed with these?

I don't like leaving a few dozen non-compiling header files into uapi.

-Mikko
