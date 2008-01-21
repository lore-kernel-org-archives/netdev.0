From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Mon, 21 Jan 2008 03:37:14 -0800 (PST)
Message-ID: <20080121.033714.254598863.davem@davemloft.net>
References: <20071227181439.6F59.40F06B3A@sm.sony.co.jp>
	<20080110.011602.74511551.davem@davemloft.net>
	<20080121194942.613C.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080121194942.613C.40F06B3A-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Date: Mon, 21 Jan 2008 20:23:15 +0900

> Sorry for my intermittent posts.

No problem.

I am sorry for being to busy to get back to active work
on this patch set.

> > -prism54_translate_bss(struct net_device *ndev, char *current_ev,
> > -		      char *end_buf, struct obj_bss *bss, char noise)
> > +prism54_translate_bss(struct net_device *ndev, struct iw_request_info *info,
> > +		      char *current_ev, char *end_buf, struct obj_bss *bss,
> > +		      char noise)
> >  {
> >  	struct iw_event iwe;	/* Temporary buffer */
> >  	short cap;
> 
> <snip>
> 
> > @@ -2728,9 +2730,12 @@ prism2_ioctl_scan_req(struct net_device *ndev,
> >  	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
> >  	bsslist = r.ptr;
> >  
> > +	info.cmd = PRISM54_HOSTAPD;
> > +	info.flags = 0;
> > +
> >  	/* ok now, scan the list and translate its info */
> >  	for (i = 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
> > -		current_ev = prism54_translate_bss(ndev, current_ev,
> > +		current_ev = prism54_translate_bss(ndev, current_ev, &info,
> 
> The order of the arguments is wrong.
> 
> current_ev = prism54_translate_bss(ndev, &info, current_ev,

Indeed, I will fix this up in a future version.

I will also investigate why this escaped my build testing.
It is merely a PCI driver, so it should have been included
in the "make allmodconfig" test builds I do on sparc64.

Thank you.
