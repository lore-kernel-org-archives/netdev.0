From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] add nl80211
Date: Thu, 24 Aug 2006 16:15:10 +0200
Message-ID: <1156428910.10283.1.camel@ux156>
References: <1156254768.3825.1.camel@ux156>
	 <20060824153230.5a54bb6a@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40347 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751554AbWHXOPF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 10:15:05 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060824153230.5a54bb6a@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-24 at 15:32 +0200, Jiri Benc wrote:
> > +	int	(*add_virtual_intf)(void *priv, char *name);
> 
> What about initial interface type? (Hm, maybe it can be fixed to a STA
> mode, but it should be documented somewhere at least.)

Actually, I already changed that.

> > +	int	(*del_virtual_intf)(void *priv, int ifindex);
> > +
> > +	/* more things to be added...
> > +	 *
> > +	 * for a (*configure)(...) call I'd probably guess that the
> > +	 * best bet would be to have one call that returns all
> > +	 * possible options, one that sets them based on the
> > +	 * struct genl_info *info, and one for that optimised
> > +	 * set-at-once thing.
> > +	 */
> > +};
> > +
> > +/*
> > + * register a given method structure with the nl80211 system
> > + * and associate the 'priv' pointer with it.
> > + * NOTE: for proper operation, this priv pointer MUST also be
> > + * assigned to each &struct net_device's @ieee80211_ptr member!
> > + */
> > +extern int nl80211_register(struct nl80211_ops *ops, void *priv);
> 
> Could this function return the allocated wiphy index?

Ah, yes, I wanted to do that all along. And a negative error code?

> Hm, most of drivers will need to take rtnl to stay compatible with WE.
> (Not a reason to take rtnl in nl80211, just a remark.)

Not for packet injection or such though, dev_get is enough for that, I
think.

> Please use __ prefix instead of _locked suffix (e.g.
> __nl80211_drv_by_priv). That's more common convention in the kernel.

I used to have a locking version too, which was without the suffix :)

> If both ifindex and wiphy index are set and they disagree with each
> other, this should return an error.

Ok, I can do that.

johannes
