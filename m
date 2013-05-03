From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH] Add support for netconsole driver used on
 bridge device with VIF attached
Date: Fri, 3 May 2013 10:36:32 -0400
Message-ID: <20130503143632.GB3146@phenom.dumpdata.com>
References: <1367409301.3301.21.camel@yuval-pc.mtl.com>
 <1367572270.28742.44.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval Shaia <yuval.shaia@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	bridge <bridge@lists.linux-foundation.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28991 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933918Ab3ECOgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 10:36:45 -0400
Content-Disposition: inline
In-Reply-To: <1367572270.28742.44.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 03, 2013 at 10:11:10AM +0100, Ian Campbell wrote:
> On Wed, 2013-05-01 at 12:55 +0100, Yuval Shaia wrote:
> [... snip regurgitation of the thread...]
> > 0001-Add-support-for-netconsole-driver-used-on-bridge-dev.patch
> > 0 2001
> > From: Yuval <yuval.shaia@oracle.com>
> > Date: Tue, 8 Jan 2013 10:08:45 +0200
> > Subject: [PATCH] Add support for netconsole driver used on bridge device with
> >  VIF attached
> 
> Sorry, but this is not what I was asking for.
> 
> Please submit with a coherent changelog based on (i.e. digested from)
> the previous discussion which explains why this change is necessary
> including the background of why it is being made in this way and the
> interaction with the bridging layer. I wasn't asking you to just cut and
> paste that discussion and prepend it to the commit like that.
> 
> The key point is that we don't think that doing netconsole from dom0 to
> a domU on the same host is a useful configuration or something which is
> especially desirable to support but that because of how the bridge
> handles netconsole netback needs to expose this hook in order that
> netconsole can be enabled via a physical device on the same bridge to a
> netserver elsewhere.

I would have thought that doing netconsole on a domU would be a worthwile
attempt - especially to troubleshoot a guest?

> 
> > 
> > Signed-off-by: Yuval <yuval.shaia@oracle.com>
> > ---
> >  drivers/net/xen-netback/interface.c |    8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/drivers/net/xen-netback/interface.c \
> > b/drivers/net/xen-netback/interface.c index 601ae2a..10751f5 100644
> > --- a/drivers/net/xen-netback/interface.c
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -179,6 +179,13 @@ static u32 xenvif_fix_features(struct net_device *dev, u32 \
> > features)  return features;
> >  }
> >  
> > +static void xenvif_poll_controller(struct net_device *dev)
> > +{
> > +	disable_irq(dev->irq);
> > +	xenvif_interrupt(dev->irq, dev);
> > +	enable_irq(dev->irq);
> > +}
> > +
> >  static const struct xenvif_stat {
> >  	char name[ETH_GSTRING_LEN];
> >  	u16 offset;
> > @@ -237,6 +244,7 @@ static const struct net_device_ops xenvif_netdev_ops = {
> >  	.ndo_stop	= xenvif_close,
> >  	.ndo_change_mtu	= xenvif_change_mtu,
> >  	.ndo_fix_features = xenvif_fix_features,
> > +	.ndo_poll_controller = xenvif_poll_controller,
> >  };
> >  
> >  struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
> 
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
> 
