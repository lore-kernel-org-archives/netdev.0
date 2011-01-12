From: Joe Perches <joe@perches.com>
Subject: Re: [uclinux-dist-devel] [PATCH net-next-2.6] netdev: bfin_mac:
 Use is_multicast_ether_addr helper
Date: Wed, 12 Jan 2011 09:18:01 -0800
Message-ID: <1294852681.4114.6.camel@Joe-Laptop>
References: <1294824611-10483-1-git-send-email-tklauser@distanz.ch>
	 <AANLkTimztPZB3N+ZYNsDM9L3ZEM+x__bBc-JCRgO8iDC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tobias Klauser <tklauser@distanz.ch>,
	Michael Hennerich <michael.hennerich@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3099 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754691Ab1ALRSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 12:18:04 -0500
In-Reply-To: <AANLkTimztPZB3N+ZYNsDM9L3ZEM+x__bBc-JCRgO8iDC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-12 at 11:38 -0500, Mike Frysinger wrote:
> On Wed, Jan 12, 2011 at 04:30, Tobias Klauser wrote:
> > --- a/drivers/net/bfin_mac.c
> > +++ b/drivers/net/bfin_mac.c
> > @@ -1293,7 +1293,7 @@ static void bfin_mac_multicast_hash(struct net_device *dev)
> >                addrs = ha->addr;
> >
> >                /* skip non-multicast addresses */
> > -               if (!(*addrs & 1))
> > +               if (!is_multicast_ether_addr(addrs))
> >                        continue;
> 
> looks good to me ...
> Acked-by: Mike Frysinger <vapier@gentoo.org>

Does a netdev_for_each_mc_addr loop entry really
need to verify that the address is multicast?

Couldn't this just be:

	netdev_for_each_mc_addr(ha, dev) {
		crc = ether_crc(ETH_ALEN, ha->addr);
		crc >>= 26;

		if (crc & 0x20)
			emac_hashhi |= 1 << (crc & 0x1f);
		else
			emac_hashlo |= 1 << (crc & 0x1f);
	}


