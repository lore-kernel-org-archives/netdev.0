From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] intel: make wired ethernet driver message
 level consistent
Date: Sat, 10 Mar 2012 16:44:35 -0800
Message-ID: <20120310164435.70bcd0e5@nehalam.linuxnetplumber.net>
References: <20120310084921.GA4647@elgon.mountain>
	<20120310160153.1d3e5f19@nehalam.linuxnetplumber.net>
	<1331426337.3022.106.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	Peter, "David S. Miller" <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1331426337.3022.106.camel@deadeye>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, 11 Mar 2012 00:38:57 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Sat, 2012-03-10 at 16:01 -0800, Stephen Hemminger wrote:
> > Dan Carpenter noticed that ixgbevf initial default was different than
> > the rest. But the problem is broader than that, only one Intel driver (ixgb)
> > was doing it right.
> > 
> > The convention for default debug level should be consistent among
> > Intel drivers and follow established convention.
> [...]
> > --- a/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-02-27 08:43:02.348936997 -0800
> > +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-03-10 15:50:57.199452804 -0800
> > @@ -215,7 +215,8 @@ MODULE_DESCRIPTION("Intel(R) PRO/1000 Ne
> >  MODULE_LICENSE("GPL");
> >  MODULE_VERSION(DRV_VERSION);
> >  
> > -static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
> > +#define DEFAULT_DEBUG_LEVEL_SHIFT 3
> 
> Wonder if this should really be 2 (enable DRV and PROBE) or 3 (enable
> DRV, PROBE and LINK; equivalent to current behaviour)?

That is really up to intel, the link up/down is useful, but nuisance
with lots of devices.

> > +static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
> >  module_param(debug, int, 0);
> >  MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
> >  
> > @@ -979,7 +980,7 @@ static int __devinit e1000_probe(struct
> >  	adapter = netdev_priv(netdev);
> >  	adapter->netdev = netdev;
> >  	adapter->pdev = pdev;
> > -	adapter->msg_enable = (1 << debug) - 1;
> > +	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
> [...]
> 
> This works, but not the way you intended.  The first parameter is
> supposed to be a module parameter with a default of -1.  The second
> parameter is supposed to be the bitmask to use when that default is not
> overridden.

I'll fix that.



------------------------------------------------------------------------------
Virtualization & Cloud Management Using Capacity Planning
Cloud computing makes use of virtualization - but cloud computing 
also focuses on allowing computing to be delivered as a service.
http://www.accelacomm.com/jaw/sfnl/114/51521223/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
