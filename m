From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH 2.6.10-rc1 15/15] wireless/orinoco: Wireless scanning support
Date: Wed, 27 Oct 2004 14:06:24 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027040624.GC1676@zax>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098818888.9874.6.camel@dcbw.boston.redhat.com> <20041026193355.GA22696@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@oss.sgi.com, jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041026193355.GA22696@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 09:33:56PM +0200, Francois Romieu wrote:
> [...]
> > +++ b/drivers/net/wireless/orinoco.c	2004-08-17 17:26:31.000000000 -0400
> > @@ -1442,6 +1442,80 @@
> >  	       dev->name, s, status);
> >  }
> >  
> > +/* Search scan results for requested BSSID, join it if found */
> > +static void orinoco_join_ap(struct net_device *dev)
> > +{
> > +	struct orinoco_private *priv = netdev_priv(dev);
> > +	struct hermes *hw = &priv->hw;
> > +	int err;
> > +	unsigned long flags;
> > +	struct join_req {
> > +		u8 bssid[ETH_ALEN];
> > +		u16 channel;
> > +	} __attribute__ ((packed)) req;
> > +	const int atom_len = offsetof(struct prism2_scan_apinfo, atim);
> > +	struct prism2_scan_apinfo *atom;
> > +	int offset = 4;
> > +	int found = 0;
> > +	u8 *buf = NULL;
> > +	u16 len;
> > +
> > +	/* Allocate buffer for scan results */
> > +	buf = kmalloc(MAX_SCAN_LEN, GFP_KERNEL);
> > +	if (!buf)
> > +		return;
> > +
> > +	if (orinoco_lock(priv, &flags) != 0)
> > +		return;
> 
> Leak.

Indeed.  Fix committed to CVS.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
