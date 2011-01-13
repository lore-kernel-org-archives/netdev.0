From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 13 Jan 2011 15:22:39 +0100
Message-ID: <1294928559.3570.130.camel@edumazet-laptop>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 13 janvier 2011 =C3=A0 19:49 +0800, Po-Yu Chuang a =C3=A9crit =
:
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>=20
> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
> MII.  This driver has been working on some ARM/NDS32 SoC including
> Faraday A320 and Andes AG101.
>=20
> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
> ---
>  drivers/net/Kconfig    |    9 +
>  drivers/net/Makefile   |    1 +
>  drivers/net/ftmac100.c | 1341 ++++++++++++++++++++++++++++++++++++++=
++++++++++
>  drivers/net/ftmac100.h |  180 +++++++
>  4 files changed, 1531 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/ftmac100.c
>  create mode 100644 drivers/net/ftmac100.h

Hi

1) please use netdev_alloc_skb_ip_align() instead of dev_alloc_skb() +
skb_reserve(skb, NET_IP_ALIGN);

2) Dont include a "struct net_device_stats stats" in struct ftmac100,
you can use the one included in struct net_device
  (You can then remove ftmac100_get_stats())

3) Dont "netdev->last_rx =3D jiffies;" : This is not driver job.
 Ditto for trans_start

4) You must comment why wmb() is needed in ftmac100_xmit()

5) Why isnt NAPI used too for TX completions ?
   BTW, I am not sure we want a define. All new drivers must use NAPI.

6) Use is_valid_ether_addr() instead of is_zero_ether_addr() in
ftmac100_probe()

7) "static struct ethtool_ops ftmac100_ethtool_ops" should be const :
	"static const struct ethtool_ops ftmac100_ethtool_ops"
  Ditto for :
	"static struct net_device_ops ftmac100_netdev_ops"


8) Why an interrupt handler (ftmac100_interrupt()) needs to block
interrupts with spin_lock_irqsave(&priv->hw_lock, flags); ?

9) Instead of dev_info(&netdev->dev ...) , please consider netdev_info(=
)
