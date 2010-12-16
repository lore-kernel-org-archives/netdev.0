From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH v2] e1000e: convert to stats64
Date: Thu, 16 Dec 2010 11:10:21 -0200
Message-ID: <20101216131021.GA20139@redhat.com>
References: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
	<1292362173.2478.6.camel@edumazet-laptop>
	<20101216123131.GA3070@redhat.com>
	<1292503830.2883.92.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1292503830.2883.92.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Dec 16, 2010 at 01:50:30PM +0100, Eric Dumazet wrote:
> Le jeudi 16 d=E9cembre 2010 =E0 10:31 -0200, Flavio Leitner a =E9crit :
> =

> > -static struct net_device_stats *e1000_get_stats(struct net_device *net=
dev)
> > +struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
> > +						   struct rtnl_link_stats64 *stats)
> >  {
> > -	/* only return the current stats */
> > -	return &netdev->stats;
> > +	struct e1000_adapter *adapter =3D netdev_priv(netdev);
> > +
> > +	memset(stats, 0, sizeof(struct rtnl_link_stats64));
> =

> You dont need this memset(), stats is cleared by caller (dev_get_stats()
> in net/core/dev.c), as this was always done ;)

Yes, but e1000_get_ethtool_stats() also calls it and doesn't do that.
I could move the memset to the caller, but I thought it would be cleaner
to leave where it is now.

 =

> > +	spin_lock(&adapter->stats64_lock);
> > +	e1000e_update_stats(adapter);
> > +	/* Fill out the OS statistics structure */
> > +	stats->rx_bytes =3D adapter->stats.gorc;
> > +	stats->rx_packets =3D adapter->stats.gprc;
> > +	stats->tx_bytes =3D adapter->stats.gotc;
> > +	stats->tx_packets =3D adapter->stats.gptc;
> > +	stats->multicast =3D adapter->stats.mprc;
> > +	stats->collisions =3D adapter->stats.colc;
> > +
> =

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- =

Flavio

---------------------------------------------------------------------------=
---
Lotusphere 2011
Register now for Lotusphere 2011 and learn how
to connect the dots, take your collaborative environment
to the next level, and enter the era of Social Business.
http://p.sf.net/sfu/lotusphere-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
