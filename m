From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 01 Mar 2011 08:27:00 +0100
Message-ID: <1298964420.2676.59.camel@edumazet-laptop>
References: <1298627845-1583-1-git-send-email-ratbert.chuang@gmail.com>
	 <1298962129-1605-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298962129-1605-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 01 mars 2011 =C3=A0 14:48 +0800, Po-Yu Chuang a =C3=A9crit :
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>=20
> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
> MII.  This driver has been working on some ARM/NDS32 SoC's including
> Faraday A320 and Andes AG101.
>=20
> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
> ---
> v2:
> always use NAPI
> do not use our own net_device_stats structure
> don't set trans_start and last_rx
> stats.rx_packets and stats.rx_bytes include dropped packets
> add missed netif_napi_del()
> initialize spinlocks in probe function
> remove rx_lock and hw_lock
> use netdev_[err/info/dbg] instead of dev_* ones
> use netdev_alloc_skb_ip_align()
> remove ftmac100_get_stats()
> use is_valid_ether_addr() instead of is_zero_ether_addr()
> add const to ftmac100_ethtool_ops and ftmac100_netdev_ops
> use net_ratelimit() instead of printk_ratelimit()
> no explicit inline
> use %pM to print MAC address
> add comment before wmb
> use napi poll() to handle all interrupts
>=20
> v3:
> undo "stats.rx_packets and stats.rx_bytes include dropped packets"
> ftmac100_mdio_read() returns 0 if error
> fix comment typos
> use pr_fmt and pr_info
> define INT_MASK_ALL_ENABLED
> define MACCR_ENABLE_ALL
> do not count length error many times
> use bool/true/false
> use cpu_to_le32/le32_to_cpu to access descriptors
> indent style fix
>=20
> v4:
> should not access skb after netif_receive_skb()
> use resource_size()
> better way to use cpu_to_le32/le32_to_cpu
> use spin_lock() for tx_lock
> combine all netdev_info() together in ftmac100_poll()
>=20
> v5:
> use dev_kfree_skb() in ftmac100_tx_complete_packet()
> cpu_to_le32/le32_to_cpu usage fix
> drop GFP_DMA
>=20
> v6:
> cpu_to_le32/le32_to_cpu usage fix
> remove "tx queue full" message
> reduce critical section protected by tx_lock
> add check of MAX_PKT_SIZE and RX_BUF_SIZE
> add __exit to ftmac100_remove()
> simplify ftmac100_rx_packet()
> zero copy - use skb_fill_page_desc() and __pskb_pull_tail().
> pull more data to skb head to include tcp/ip header
>=20
> v7:
> allocate 128 bytes skb and pull 64 bytes only
>=20
>  drivers/net/Kconfig    |    9 +
>  drivers/net/Makefile   |    1 +
>  drivers/net/ftmac100.c | 1196 ++++++++++++++++++++++++++++++++++++++=
++++++++++
>  drivers/net/ftmac100.h |  180 ++++++++
>  4 files changed, 1386 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/ftmac100.c
>  create mode 100644 drivers/net/ftmac100.h

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
