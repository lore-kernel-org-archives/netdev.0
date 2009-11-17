From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [RFC] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 09:06:27 -0500
Message-ID: <20091117140626.GE27743@tuxdriver.com>
References: <1258465585.3682.7.camel@johannes.local> <200911171504.54170.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200911171504.54170.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 17, 2009 at 03:04:52PM +0100, Michael Buesch wrote:
> On Tuesday 17 November 2009 14:46:25 Johannes Berg wrote:
> > --- wireless-testing.orig/net/bridge/br_if.c	2009-11-17 14:19:17.000000000 +0100
> > +++ wireless-testing/net/bridge/br_if.c	2009-11-17 14:20:03.000000000 +0100
> > @@ -390,6 +390,10 @@ int br_add_if(struct net_bridge *br, str
> >  	if (dev->br_port != NULL)
> >  		return -EBUSY;
> >  
> > +	/* No bridging devices that dislike that (e.g. wireless) */
> > +	if (dev->priv_flags & IFF_DONT_BRIDGE)
> > +		return -EINVAL;
> 
> -EOPNOTSUPP?
> That would probably produce a better error message in userspace.

Yes, good point.

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
