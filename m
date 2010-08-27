From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] wireless: fix 64K kernel heap content leak via ioctl
Date: Fri, 27 Aug 2010 15:39:26 -0700
Message-ID: <20100827223926.GB32498@bougret.hpl.hp.com>
References: <20100827210240.GC4703@outflux.net> <20100827212254.GB32275@bougret.hpl.hp.com> <AANLkTimeEa_=dqX5yFnYzaSaL90TfOg3=MsydG81naAC@mail.gmail.com>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimeEa_=dqX5yFnYzaSaL90TfOg3=MsydG81naAC-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 27, 2010 at 03:35:19PM -0700, Luis R. Rodriguez wrote:
> >
> > diff -u -p wext.j2.c wext.c
> > --- wext.j2.c   2010-08-27 14:17:26.000000000 -0700
> > +++ wext.c      2010-08-27 14:19:33.000000000 -0700
> > @@ -800,9 +800,12 @@ static int ioctl_standard_iw_point(struc
> >                        goto out;
> >                }
> >
> > -               if (copy_to_user(iwp->pointer, extra,
> > -                                iwp->length *
> > -                                descr->token_size)) {
> > +               /* Verify how much we should return. Some driver
> > +                * may abuse iwp->length... */
> > +               if((iwp->length * descr->token_size) < extra_size)
> > +                       extra_size = iwp->length * descr->token_size;
> > +
> > +               if (copy_to_user(iwp->pointer, extra, extra_size)) {
> >                        err = -EFAULT;
> >                        goto out;
> >                }
> 
> 
> Jean, can you submit in a new thread and right before the SOB add in
> the commit log Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org [2.6.32+]

	The current patch was made for 2.6.27 and was only
compiled. Someone would need to verify it works for 2.6.32. I could
probably find some time next week.

>   Luis

	Regards,

	Jean
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
