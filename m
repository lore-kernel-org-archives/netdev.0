From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Wed, 06 Jun 2012 19:13:02 +0200
Message-ID: <1339002782.26966.22.camel@edumazet-glaptop>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
	 <1338972341.2760.3944.camel@edumazet-glaptop>
	 <20120606111357.GA15070@redhat.com>
	 <1338988210.2760.4485.camel@edumazet-glaptop>
	 <20120606144941.GA17092@redhat.com>
	 <1338995944.26966.6.camel@edumazet-glaptop>
	 <20120606161715.GA17575@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120606161715.GA17575@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-06-06 at 19:17 +0300, Michael S. Tsirkin wrote:

> But why do you say at most 1 packet?
> 
> Consider get_stats doing:
>                u64_stats_update_begin(&stats->syncp);
>                stats->tx_bytes += skb->len;
> 
> on 64 bit at this point
> tx_packets might get incremented any number of times, no?
> 
>                 stats->tx_packets++;
>                 u64_stats_update_end(&stats->syncp);
> 
> now tx_bytes and tx_packets are out of sync by more than 1.

You lost me there.

No idea of what you are thinking about.

There is no atomicity guarantee in SNMP counters. (Ie fetching tx_bytes
and tx_packets in a transaction is not mandatory in any RFC)

As long as there is no cumulative error, its OK.
