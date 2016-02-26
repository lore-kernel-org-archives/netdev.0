From: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Subject: Re: [PATCH] uapi glibc compat: fix cases where glibc net/if.h is
 included before linux/if.h
Date: Fri, 26 Feb 2016 09:25:13 +0200
Message-ID: <20160226072513.GH6104@lakka.kapsi.fi>
References: <CA+5PVA4P2avVr+m=ittQUyBou9kT2nbK0-Jeo+3coAFyQXTT_A@mail.gmail.com>
 <1454853801-18064-1-git-send-email-mikko.rapeli@iki.fi>
 <20160217.104620.239734387234680136.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemming-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libc-alpha-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160217.104620.239734387234680136.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(Adding libc-alpha list, review of https://lkml.org/lkml/2016/2/7/89 )

On Wed, Feb 17, 2016 at 10:46:20AM -0500, David Miller wrote:
> From: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
> Date: Sun,  7 Feb 2016 16:03:21 +0200
> 
> > @@ -68,6 +72,8 @@
> >   * @IFF_ECHO: echo sent packets. Volatile.
> >   */
> >  enum net_device_flags {
> > +/* for compatibility with glibc net/if.h */
> > +#if __UAPI_DEF_IF_NET_DEVICE_FLAGS
> >  	IFF_UP				= 1<<0,  /* sysfs */
> >  	IFF_BROADCAST			= 1<<1,  /* volatile */
> >  	IFF_DEBUG			= 1<<2,  /* sysfs */
> > @@ -84,11 +90,14 @@ enum net_device_flags {
> >  	IFF_PORTSEL			= 1<<13, /* sysfs */
> >  	IFF_AUTOMEDIA			= 1<<14, /* sysfs */
> >  	IFF_DYNAMIC			= 1<<15, /* sysfs */
> > +#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS */
> >  	IFF_LOWER_UP			= 1<<16, /* volatile */
> >  	IFF_DORMANT			= 1<<17, /* volatile */
> >  	IFF_ECHO			= 1<<18, /* volatile */
> >  };
> 
> This is going to get messy is IFF_LOWER_UP, IFF_DORMANT, and IFF_ECHO
> get added the the glibc header.  Why not just handle it now with
> another __UAPI_DEF_FOO guard so that the additions to net/if.h can
> deal with this case too.

Do you mean that the enum should be protected with a single guard or
should I have one guard for current conflicts and one for the future
if glibc headers include IFF_LOWER_UP and others?

-Mikko
