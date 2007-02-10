From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Subject: Re: [PATCH] zd1211rw: Readd zd_addr_t cast
Date: Sat, 10 Feb 2007 20:56:52 +0100
Message-ID: <20070210195652.GA16406@p15091797.pureserver.info>
References: <20070210012718.3B6E87B409F@zog.reactivated.net> <200702100702.15264.mb@bu3sch.de> <1171133498.20342.59.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rpjday-mn4gwa5WIIQysxA8WJXlww@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1171133498.20342.59.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07-02-10 10:51 Joe Perches wrote:

> On Sat, 2007-02-10 at 07:02 +0100, Michael Buesch wrote:
> > On Saturday 10 February 2007 02:27, Daniel Drake wrote:
> > > Robert P.J. Day's recent commit ("getting rid of all casts of k[cmz]alloc()
> > > calls") introduced a sparse warning for zd1211rw, related to our type-checking
> > > of addresses.
> > > > 	zd_chip.c:116:15: warning: implicit cast to nocast type
> > > This patch readds the type cast, it is correct.
> > > Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> > > Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
> > > ===================================================================
> > > --- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
> > > +++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
> > > @@ -113,7 +113,7 @@ int zd_ioread32v_locked(struct zd_chip *
> > >  
> > >  	/* Allocate a single memory block for values and addresses. */
> > >  	count16 = 2*count;
> > > -	a16 = kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
> > > +	a16 = (zd_addr_t *) kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
> > >  		                   GFP_NOFS);
> 
> I think it better to remove this __nocast instead.
> This is the only use of __nocast outside of kmem in the kernel tree.
> 
> Why not just remove __nocast and use u16 instead of zd_addr_t?

Using the __nocast type sparse catches errors, when address and
value arguments are used in the wrong order for calls of the
zd_ioread* and zd_iowrite* functions. I'm a lazy guy, I like tools
do the hard work for me. 

> If not the removal of the __nocast, would it be better to have a
> void pointer there?

I don't think that an explicit cast requires the introduction of a
temporary variable.

-- 
Uli Kunitz
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
