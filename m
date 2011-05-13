From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC 1/3] RDMA: Add netlink infrastructure
Date: Fri, 13 May 2011 10:36:07 -0700
Message-ID: <1305308167.8178.20.camel@Joe-Laptop>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
	 <1305303525-11113-2-git-send-email-roland@kernel.org>
	 <1305305065.8178.9.camel@Joe-Laptop>
	 <BANLkTikpzn6R-QH__dtmwz=fO1QMUN+qag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Nir Muchtar <nirm-smomgflXvOZWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTikpzn6R-QH__dtmwz=fO1QMUN+qag-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-05-13 at 19:18 +0200, Bart Van Assche wrote:
> On Fri, May 13, 2011 at 6:44 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> > On Fri, 2011-05-13 at 09:18 -0700, Roland Dreier wrote:
> >> From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
> >> [Dave please do not apply even if this ends up in netdev patchwork!]
> >> diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
> > []
> >> +#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
> > Using #define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
> > generally produces smaller overall object size, especially
> > at 64 bit.
> > For instance, here's the size of netlink.o at 32 bit:
> > $ size drivers/infiniband/core/netlink.o.*
> >   text    data     bss     dec     hex filename
> >   2663     153     736    3552     de0 drivers/infiniband/core/netlink.o.old
> >   2640     153     736    3529     dc9 drivers/infiniband/core/netlink.o.new
> > Also, I rarely find __func__ useful in message output.
> > It may be more useful for active development/debugging.
> A recent dynamic debug patch made it possible to enable/disable at
> runtime whether or not the function name (and more) should be included
> in the output. See also http://lwn.net/Articles/434833/ for more
> information.

One long term goal for me is a generic run-time mechanism
to prefix all pr_<level> uses not just the <foo>_dbg ones
with or without module or function name.

It will also allow the removal of all the uses of
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

New #define pr_fmt lines need to be added to the current
files that use pr_<level> without a prefix so it could
take awhile.

Eventually.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
