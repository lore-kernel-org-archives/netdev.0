From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [07/22] Cyclades PC300 driver: ioctl() fixes for mixed
 64/32-bit systems
Date: Mon, 30 Jan 2012 14:37:05 +0000
Message-ID: <1327934225.5400.443.camel@deadeye>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E3F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrea Shepard <andrea@persephoneslair.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<khc@pm.waw.pl>, <davem@davemloft.net>, <mmarek@suse.cz>,
	<jkosina@suse.cz>, <joe@perches.com>, <justinmattock@gmail.com>,
	<gregkh@suse.de>, <alan@linux.intel.com>, <jdmason@kudzu.us>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E3F@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-01-30 at 11:44 +0000, David Laight wrote:
> > +struct pc300_net_stats {
> > +	u64 rx_packets;
> ...
> > +	u64 rx_compressed;
> > +	u64 tx_compressed;
> > +};
> > +
> >  typedef struct pc300stats {
> >  	int hw_type;
> >  	u32 line_on;
> >  	u32 line_off;
> > -	struct net_device_stats gen_stats;
> > +	/* Use this instead of net_device_stats, since passing
> > +	 * net_device_stats breaks 32-bit user processes on 
> > 64-bit kernels,
> > +	 * and rtnetlink is unreasonably complicated just to get
> > +	 * some statistics.
> > +	 */
> > +	struct pc300_net_stats net_stats;
> >  	falc_t te_stats;
> >  } pc300stats_t;
> 
> Since 'struct net_device_stats' looks like a common structure,
> maybe the 64bit version should be added in the same place??
[...]

It's called struct rtnl_link_stats64 and is already defined in
<linux/rtnetlink.h> (where it must remain).

This change doesn't seem to be a proper fix.  If the ioctl interface to
this driver uses struct net_device_stats (which I didn't realise,
otherwise I would have left that structure exported from
<linux/netdevice.h>) then it should continue doing so to maintain
compatibility.  And the driver will need a compat_ioctl for that.

If backward-compatibility is really not a concern for the driver then
this ioctl should be completely removed in favour of ethtool extended
stats.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
