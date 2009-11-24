From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Tue, 24 Nov 2009 19:58:18 +0100
Message-ID: <4B0C2CCA.6030006@gmail.com>
References: <20091124.093956.247147202.davem@davemloft.net>	<1259085412.2631.48.camel@ppwaskie-mobl2>	<4B0C2547.8030408@gmail.com> <20091124.105442.06273019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: peter.p.waskiewicz.jr@intel.com, peterz@infradead.org,
	arjan@linux.intel.com, yong.zhang0@gmail.com,
	linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933942AbZKXS63@vger.kernel.org>
In-Reply-To: <20091124.105442.06273019.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 24 Nov 2009 19:26:15 +0100
>=20
>> It seems complex to me, maybe optimal thing would be to use a NUMA p=
olicy to
>> spread vmalloc() allocations to all nodes to get a good bandwidth...
>=20
> vmalloc() and sk_buff's don't currently mix and I really don't see us
> every allowing them to :-)

I think Peter was referring to tx/rx rings buffers, not sk_buffs.

They (ring buffers) are allocated with vmalloc() at driver init time.

And Tom pointed out that our rx sk_buff allocation should be using the =
node
of requester, no need to hardcode node number per rx queue (or per devi=
ce as of today)
