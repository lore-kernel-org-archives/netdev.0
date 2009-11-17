From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 08:37:41 -0800
Message-ID: <20091117083741.1b165274@nehalam>
References: <1258465585.3682.7.camel@johannes.local>
	<200911171504.54170.mb@bu3sch.de>
	<1258466868.3682.13.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1258466868.3682.13.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Nov 2009 15:07:48 +0100
Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:

> On Tue, 2009-11-17 at 15:04 +0100, Michael Buesch wrote:
> > On Tuesday 17 November 2009 14:46:25 Johannes Berg wrote:
> > > --- wireless-testing.orig/net/bridge/br_if.c	2009-11-17 14:19:17.000000000 +0100
> > > +++ wireless-testing/net/bridge/br_if.c	2009-11-17 14:20:03.000000000 +0100
> > > @@ -390,6 +390,10 @@ int br_add_if(struct net_bridge *br, str
> > >  	if (dev->br_port != NULL)
> > >  		return -EBUSY;
> > >  
> > > +	/* No bridging devices that dislike that (e.g. wireless) */
> > > +	if (dev->priv_flags & IFF_DONT_BRIDGE)
> > > +		return -EINVAL;
> > 
> > -EOPNOTSUPP?
> > That would probably produce a better error message in userspace.

But there are people bridging wireless, and hostap even has a mode for
that. Especially people are bridging to wireless when the other interfaces
are VMs.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
