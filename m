From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Subject: RE: [Patch 1/2] s2io: add dynamic LRO disable support
Date: Sat, 5 Jun 2010 01:53:25 -0700
Message-ID: <FCA91A92EE52B041906A0358FC28FCC38EF129DB8F@FRE1EXCH02.hq.exar.com>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>
 <20100603153811.7b14a1a8@leela>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amerigo Wang <amwang@redhat.com>,
	"herbert.xu@redhat.com" <herbert.xu@redhat.com>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Michal Schmidt <mschmidt@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:8852 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932555Ab0FEI6e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 04:58:34 -0400
In-Reply-To: <20100603153811.7b14a1a8@leela>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
> +{
> +	struct s2io_nic *sp = netdev_priv(dev);
> +	int rc = 0;
> +	int changed = 0;
> +
> +	if (data & ETH_FLAG_LRO) {
> +		if (lro_enable) {
> +			if (!(dev->features & NETIF_F_LRO)) {
> +				dev->features |= NETIF_F_LRO;
> +				changed = 1;
> +			}
> +		} else
> +			rc = -EINVAL;
> +	} else if (dev->features & NETIF_F_LRO) {
> +		dev->features &= ~NETIF_F_LRO;
> +		changed = 1;
> +	}
> +
> +	if (changed && netif_running(dev)) {
> +		s2io_stop_all_tx_queue(sp);
> +		s2io_card_down(sp);
> +		sp->lro = dev->features & NETIF_F_LRO;
> +		rc = s2io_card_up(sp);
In s2io_card_up, update ring->lro too as it is used in the fast path -
		struct ring_info *ring = &mac_control->rings[i];
 
 		ring->mtu = dev->mtu;
+		ring->lro = sp->lro;

> +		s2io_start_all_tx_queue(sp);

The following line in init_shared_mem() is redundant and can be removed.
-	ring->lro = lro_enable;

Thanks,
Ram
