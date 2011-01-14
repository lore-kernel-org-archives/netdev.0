From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: remove dev_txq_stats_fold()
Date: Thu, 13 Jan 2011 21:45:04 -0800 (PST)
Message-ID: <20110113.214504.37217354.davem@davemloft.net>
References: <20110112210518.GA2152@del.dom.local>
	<20110112211806.GB2152@del.dom.local>
	<1294870394.3335.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org, neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org, sandeep.kumar-KZfg59tc24xl57MIdRCFDg@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1294870394.3335.75.camel@edumazet-laptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 12 Jan 2011 23:13:14 +0100

> [PATCH v2] net: remove dev_txq_stats_fold()
> 
> After recent changes, (percpu stats on vlan/tunnels...), we dont need
> anymore per struct netdev_queue tx_bytes/tx_packets/tx_dropped counters.
> 
> Only remaining users are ixgbe, sch_teql, gianfar & macvlan :
> 
> 1) ixgbe can be converted to use existing tx_ring counters.
> 
> 2) macvlan incremented txq->tx_dropped, it can use the
> dev->stats.tx_dropped counter.
> 
> 3) sch_teql : almost revert ab35cd4b8f42 (Use net_device internal stats)
>     Now we have ndo_get_stats64(), use it, even for "unsigned long"
> fields (No need to bring back a struct net_device_stats)
> 
> 4) gianfar adds a stats structure per tx queue to hold
> tx_bytes/tx_packets
> 
> This removes a lockdep warning (and possible lockup) in rndis gadget,
> calling dev_get_stats() from hard IRQ context.
> 
> Ref: http://www.spinics.net/lists/netdev/msg149202.html
> 
> Reported-by: Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> CC: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> CC: Sandeep Gopalpet <sandeep.kumar-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> CC: Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>

Applied, thanks everyone.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
