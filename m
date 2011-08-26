From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH 3/3 net-next] net: Define NETDEV_FCOE_WWNN,
 NETDEV_FCOE_WWPN only when CONFIG_LIBFCOE is enabled
Date: Fri, 26 Aug 2011 15:17:50 -0700
Message-ID: <20110826151750.fc23190e.rdunlap@xenotime.net>
References: <1314387941-2126-1-git-send-email-mchan@broadcom.com>
	<1314387941-2126-2-git-send-email-mchan@broadcom.com>
	<1314387941-2126-3-git-send-email-mchan@broadcom.com>
	<5A9BD224CEA58D4CB62235967D650C160A06D10A@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bhanu Prakash Gollapudi <bprakash@broadcom.com>
To: "Zou, Yi" <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy8-pub.bluehost.com ([69.89.22.20]:49307 "HELO
	oproxy8-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750828Ab1HZWRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 18:17:52 -0400
In-Reply-To: <5A9BD224CEA58D4CB62235967D650C160A06D10A@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Aug 2011 15:11:17 -0700 Zou, Yi wrote:

> > From: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> > 
> > bnx2fc driver calls netdev->netdev_ops->ndo_fcoe_get_wwn() and it may not
> > be defined with the current Kconfig dependencies.  ndo_fcoe_get_wwn is
> > dependent on CONFIG_FCOE, but bnx2fc does not select CONFIG_FCOE, as it
> > does
> > not depend on fcoe driver. Since both fcoe and bnx2fc drivers select
> > CONFIG_LIBFCOE, define NETDEV_FCOE_WWNN and NETDEV_FCOE_WWPN when
> > CONFIG_LIBFCOE is defined.
> > 
> > Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> > Cc: Yi Zou <yi.zou@intel.com>
> > Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > ---
> >  include/linux/netdevice.h |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 125f9fb..0a7f619 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -922,11 +922,15 @@ struct net_device_ops {
> >  						       u16 xid,
> >  						       struct scatterlist *sgl,
> >  						       unsigned int sgc);
> > +#endif
> > +
> > +#if defined(CONFIG_LIBFCOE) || defined(CONFIG_LIBFCOE_MODULE)
> >  #define NETDEV_FCOE_WWNN 0
> >  #define NETDEV_FCOE_WWPN 1
> >  	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
> >  						    u64 *wwn, int type);
> >  #endif
> > +
> >  #ifdef CONFIG_RFS_ACCEL
> >  	int			(*ndo_rx_flow_steer)(struct net_device *dev,
> >  						     const struct sk_buff *skb,
> > --
> > 1.7.1
> > 
> Thanks,
> 
> Reviewed-by: Yi Zou <yi.zou@intel.com>

Acked-by: Randy Dunlap <rdunlap@xenotime.net>

This one fixes lots of build errors, like:

drivers/scsi/fcoe/fcoe_transport.c:152: error: 'const struct net_device_ops' has no member named 'ndo_fcoe_get_wwn'

drivers/scsi/bnx2fc/bnx2fc_fcoe.c:765: error: 'NETDEV_FCOE_WWNN' undeclared (first use in this function)
drivers/scsi/bnx2fc/bnx2fc_fcoe.c:771: error: 'NETDEV_FCOE_WWPN' undeclared (first use in this function)
drivers/scsi/fcoe/fcoe_transport.c:152: error: 'const struct net_device_ops' has no member named 'ndo_fcoe_get_wwn'


thanks,
---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
