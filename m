From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [RFC PATCH] convert ebt_ulog to nfnetlink_log
Date: Sun, 07 Aug 2005 21:27:56 +0000
Message-ID: <1123450076.3378.18.camel@localhost.localdomain>
References: <20050730110353.GD6620@rama.de.gnumonks.org>
	<20050730.210423.111177162.davem@davemloft.net>
	<20050731070509.GD3835@rama.de.gnumonks.org>
	<1123241167.3377.15.camel@localhost.localdomain>
	<20050805163709.GF4033@rama.de.gnumonks.org>
	<20050805171028.GA7855@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20050805171028.GA7855@rama.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Op vr, 05-08-2005 te 19:10 +0200, schreef Harald Welte:
> What about the following (only compile-tested) patch ?
> 
> [NETFILTER] add phys{in,out}dev support to nfnetlink_log and nfnetlink_queue
> 
> Since bridges don't have a 'reasonable' input and output net_device
> (e.g. 'br0'), we need to add seperate TLV's for the 'physindev' and 'physoutdev'
> to get to the real underlying device (e.g. 'eth0').
> 
> I really hate to have those CONFIG_BRIDGE_NETFILTER ifdef's all over the
> code - but for now we have them almost everywhere, so two more doesn't
> hurt.  At some point we need to get rid of this ugliness and have something
> like an 'input device stack' that can be traversed.

I'm not sure if I understand that, how could this be used to know if
BRIDGE_NETFILTER was configured?


> +#ifdef CONFIG_BRIDGE_NETFILTER
> +		if (indev->br_port) {
> +			tmp_uint = htonl(indev->br_port->br->dev->ifindex);
> +			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
> +				sizeof(tmp_uint), &tmp_uint);
> +		}

indev->br_port->br->dev->ifindex points to the ifindex of the bridge br0
when indev is a bridge port (eth0). So you need this to fill in the
input device (assuming we agree that the bridge is called the input
device, and the bridge port is called the physical input device).
Filling in the physical input device is done with indev (in case
indev->br_port is not NULL).

I can't easily get access to net-2.6.14, so I can't have a full view on
things. If you were to change ebt_ulog, you must also make sure that the
physindev is used for NFULA_IFINDEX_PHYSINDEV. The input_dev member of
the skb will be eth0 if the physindev is known.

Analogous comments hold for the other similar parts of your patch.

cheers,
Bart
