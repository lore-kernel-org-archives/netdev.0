From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 1/4] net:ethernet:aquantia: Setup max_mtu in ndev to
 enable jumbo frames
Date: Thu, 21 Sep 2017 17:36:19 +0200
Message-ID: <20170921153619.GG27589@lunn.ch>
References: <cover.1505915085.git.igor.russkikh@aquantia.com>
 <1b556b3a2fd12c566912541f3c969d4bdc5dde9c.1505915085.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>
To: Igor Russkikh <igor.russkikh@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:51422 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751602AbdIUPgW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 11:36:22 -0400
Content-Disposition: inline
In-Reply-To: <1b556b3a2fd12c566912541f3c969d4bdc5dde9c.1505915085.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -283,6 +282,8 @@ int aq_nic_ndev_init(struct aq_nic_s *self)
>  	self->ndev->features = aq_hw_caps->hw_features;
>  	self->ndev->priv_flags = aq_hw_caps->hw_priv_flags;
>  	self->ndev->mtu = aq_nic_cfg->mtu - ETH_HLEN;
> +	self->ndev->min_mtu = ETH_MIN_MTU;

This is not required. It will default to ETH_MIN_MTU.

     Andrew

> +	self->ndev->max_mtu = self->aq_hw_caps.mtu - ETH_FCS_LEN - ETH_HLEN;
>  
>  	return 0;
>  }
> @@ -695,7 +696,7 @@ int aq_nic_set_mtu(struct aq_nic_s *self, int new_mtu)
>  {
>  	int err = 0;
>  
> -	if (new_mtu > self->aq_hw_caps.mtu) {
> +	if (new_mtu + ETH_FCS_LEN > self->aq_hw_caps.mtu) {

If you have set max_mtu correctly, this cannot happen.  But it seems
odd you don't have ETH_HLEN here, where as when setting max_mtu you
do.

   Andrew
