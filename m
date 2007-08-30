From: "Jesper Juhl" <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 13/30] net: Don't do pointless kmalloc return value casts in zd1211 driver
Date: Thu, 30 Aug 2007 22:20:23 +0200
Message-ID: <9a8748490708301320o49d8e794vc5c37ffc938006f1@mail.gmail.com>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
	 <d551047daed1cb4d9de1eff956268a468c9837f6.1187912217.git.jesper.juhl@gmail.com>
	 <46D70467.1040109@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Ulrich Kunitz" <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Daniel Drake" <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46D70467.1040109-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 30/08/2007, Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org> wrote:
> Jesper Juhl wrote:
> > Since kmalloc() returns a void pointer there is no reason to cast
> > its return value.
> > This patch also removes a pointless initialization of a variable.
>
> NAK: adds a sparse warning
> zd_chip.c:116:15: warning: implicit cast to nocast type
>
Ok, I must admit I didn't check with sparse since it seemed pointless
- we usually never cast void pointers to other pointer types,
specifically because the C language nicely guarantees that the right
thing will happen without the cast.  Sometimes we have to cast them to
integer types, su sure we need the cast there.   But what on earth
makes a "zd_addr_t *" so special that we have to explicitly cast a
"void *" to that type?

I see it's defined as
  typedef u32 __nocast zd_addr_t;
in drivers/net/wireless/zd1211rw/zd_types.h , but why the __nocast ?

What would be wrong in applying my patch that removes the cast of the
kmalloc() return value and then also remove the "__nocast" here?


-- 
Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
