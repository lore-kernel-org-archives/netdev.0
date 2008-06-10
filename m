From: Malli <mchilakala@gmail.com>
Subject: Re: [PATCH 2/2] ixgbe: add LRO support
Date: Tue, 10 Jun 2008 12:33:28 -0700
Message-ID: <7991c5480806101233u66840348s5a79164e396d0db5@mail.gmail.com>
References: <20080609225658.1219.89600.stgit@localhost.localdomain>
	<20080609225722.1219.51519.stgit@localhost.localdomain>
	<20080609232627.GM11300@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1780388237=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, jeff@garzik.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080609232627.GM11300@solarflare.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============1780388237==
Content-Type: multipart/alternative;
	boundary="----=_Part_14334_9931109.1213126408679"

------=_Part_14334_9931109.1213126408679
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thanks for your feedback Ben. I'll update the patch with ethtool get and set
flags. But in packet split mode we still wouldn't want to limit this with
MAX_SKB_FRAGS because we don't actually add the frags to the previous
packet.  They just chain them together using the frag_list and next pointers
in the skb. Let me know if it still doesn't address your concern in max
aggregation.
Thanks & Regards
-Malli

On Mon, Jun 9, 2008 at 4:26 PM, Ben Hutchings <bhutchings@solarflare.com>
wrote:

> Jeff Kirsher wrote:
> > Support for in-kernel LRO
> >
> > Signed-off-by: Mallikarjuna R Chilakala <
> mallikarjuna.chilakala@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >
> >  drivers/net/ixgbe/ixgbe.h         |    9 +++
> >  drivers/net/ixgbe/ixgbe_ethtool.c |    9 +++
> >  drivers/net/ixgbe/ixgbe_main.c    |  111
> ++++++++++++++++++++++++++++++-------
> >  3 files changed, 108 insertions(+), 21 deletions(-)
> >
> > diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
> > index d981134..956914a 100644
> > --- a/drivers/net/ixgbe/ixgbe.h
> > +++ b/drivers/net/ixgbe/ixgbe.h
> > @@ -32,6 +32,7 @@
> >  #include <linux/types.h>
> >  #include <linux/pci.h>
> >  #include <linux/netdevice.h>
> > +#include <linux/inet_lro.h>
> >
> >  #include "ixgbe_type.h"
> >  #include "ixgbe_common.h"
> > @@ -100,6 +101,9 @@
> >  #define IXGBE_TX_FLAGS_VLAN_MASK     0xffff0000
> >  #define IXGBE_TX_FLAGS_VLAN_SHIFT    16
> >
> > +#define IXGBE_MAX_LRO_DESCRIPTORS       8
> > +#define IXGBE_MAX_LRO_AGGREGATE         32
>
> I think this is supposed to be <= MAX_SKB_FRAGS, though that's only
> critical if you aggregating pages.
>
> [...]
> > @@ -3517,6 +3585,7 @@ static int __devinit ixgbe_probe(struct pci_dev
> *pdev,
> >                          NETIF_F_HW_VLAN_RX |
> >                          NETIF_F_HW_VLAN_FILTER;
> >
> > +     netdev->features |= NETIF_F_LRO;
>
> There needs to be a way of turning LRO off.  It should be sufficient
> to add:
>
>        .get_flags =    ethtool_op_get_flags,
>        .set_flags =    ethtool_op_set_flags,
>
> to your ethtool_ops.  A module parameter to set the default might be
> worthwhile too.
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

------=_Part_14334_9931109.1213126408679--


--===============1780388237==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============1780388237==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--===============1780388237==--
