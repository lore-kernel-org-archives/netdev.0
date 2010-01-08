From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] drivers/net/skfp/skfddi.c: use %pMF to show MAC address
Date: Fri, 8 Jan 2010 13:52:06 +1100
Message-ID: <20100108025206.GC2465@verge.net.au>
References: <201001071627.46569.hartleys@visionengravers.com>
 <20100108000224.GH2436@verge.net.au>
 <1262915005.10429.92.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753420Ab0AHCwM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1262915005.10429.92.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 07, 2010 at 05:43:25PM -0800, Joe Perches wrote:
> On Fri, 2010-01-08 at 11:02 +1100, Simon Horman wrote:
> > On Thu, Jan 07, 2010 at 04:27:46PM -0700, H Hartley Sweeten wrote:
> > > Use the %pMF kernel extension to display the MAC address.
> > > The address will still be displayed in the FDDI Canonical format.
> 
> > I'm not sure that it matters, but prior to this patch
> > the address was displayed with octets delimited by spaces,
> > and afterwards its delimited by hyphens. So perhaps the comment
> > should read:
> > 
> > The address will now be displayed in the FDDI Canonical format.
> 
> And it probably wasn't bit reversed.
> 
> > > diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
> > > index db216a7..1f9698c 100644
> > > --- a/drivers/net/skfp/skfddi.c
> > > +++ b/drivers/net/skfp/skfddi.c
> > > @@ -435,13 +435,7 @@ static  int skfp_driver_init(struct net_device *dev)
> > >  		goto fail;
> > >  	}
> > >  	read_address(smc, NULL);
> > > -	pr_debug(KERN_INFO "HW-Addr: %02x %02x %02x %02x %02x %02x\n",
> > > -	       smc->hw.fddi_canon_addr.a[0],
> > > -	       smc->hw.fddi_canon_addr.a[1],
> > > -	       smc->hw.fddi_canon_addr.a[2],
> > > -	       smc->hw.fddi_canon_addr.a[3],
> > > -	       smc->hw.fddi_canon_addr.a[4],
> > > -	       smc->hw.fddi_canon_addr.a[5]);
> > > +	pr_debug(KERN_INFO "HW-Addr: %pMF\n", smc->hw.fddi_canon_addr.a);
> 
> Is fddi_canon_addr already bit reversed?
> It's memcpy'd to dev->dev_addr later, so probably not.
>  
> > >  	smt_reset_defaults(smc, 0);
> > > @@ -890,15 +884,8 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
> > >  							  (struct fddi_addr *)dmi->dmi_addr, 
> > >  							  1);
> > >  
> > > -					pr_debug(KERN_INFO "ENABLE MC ADDRESS:");
> > > -					pr_debug(" %02x %02x %02x ",
> > > -					       dmi->dmi_addr[0],
> > > -					       dmi->dmi_addr[1],
> > > -					       dmi->dmi_addr[2]);
> > > -					pr_debug("%02x %02x %02x\n",
> > > -					       dmi->dmi_addr[3],
> > > -					       dmi->dmi_addr[4],
> > > -					       dmi->dmi_addr[5]);
> > > +					pr_debug(KERN_INFO "ENABLE MC ADDRESS: %pMF\n",
> > > +						dmi->dmi_addr);
> 
> I think you want %pM here, not the bit-reversed %pMF form.
> 

Keeping in mind that %pM uses ':' as the delimiter and %pMF uses '-',
which by all accounts is not the FDDI canonical format. But then again,
neither is the current use of ' ' as the delimiter.

... seems like there is some discussion surrounding the other patch in the
series and what the format and bit-order should be.
