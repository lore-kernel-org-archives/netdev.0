From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 03/10] net: add IEEE 802.15.4 socket family
	implementation
Date: Thu, 4 Jun 2009 09:46:06 -0400
Message-ID: <20090604134455.GB2839@tuxdriver.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com> <20090603173214.6d3997f7.akpm@linux-foundation.org> <20090604111634.GA28064@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090604111634.GA28064-nIupHZaCssqR2kOLt6zJ8ErlnG4Plg33XqFh9Ls21Oc@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 04, 2009 at 03:16:34PM +0400, Dmitry Eremin-Solenikov wrote:
> On Wed, Jun 03, 2009 at 05:32:14PM -0700, Andrew Morton wrote:
> > On Mon,  1 Jun 2009 18:54:44 +0400
> > Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> > > +	switch (addr->addr_type) {
> > > +	case IEEE802154_ADDR_LONG:
> > > +		rtnl_lock();
> > > +		dev = dev_getbyhwaddr(net, ARPHRD_IEEE802154, addr->hwaddr);
> > > +		if (dev)
> > > +			dev_hold(dev);
> > > +		rtnl_unlock();
> > > +		break;
> > > +	case IEEE802154_ADDR_SHORT:
> > > +		if (addr->pan_id != 0xffff && addr->short_addr != IEEE802154_ADDR_UNDEF && addr->short_addr != 0xffff) {
> > > +			struct net_device *tmp;
> > > +
> > > +			rtnl_lock();
> > > +
> > > +			for_each_netdev(net, tmp) {
> > > +				if (tmp->type == ARPHRD_IEEE802154) {
> > > +					if (IEEE802154_MLME_OPS(tmp)->get_pan_id(tmp) == addr->pan_id
> > > +					  && IEEE802154_MLME_OPS(tmp)->get_short_addr(tmp) == addr->short_addr) {
> > 
> > You must use very wide xterms :(
> 
> ~120 chars in width :)  We prefer to have a single code line split between
> several screen lines, rather than split it manually in some weird places
> just to justify width of 80 chars.

Hopefully you realize that many find this difficult to read -- I just
can't spread my eyes far enough to comprehend the lines.

80 chars is not a hard limit, but it is a good goal.  120 is too wide.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
