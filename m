From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 11/12] net: ethernet: aquantia: Fixed memory
 allocation if AQ_CFG_RX_FRAME_MAX > 1 page.
Date: Fri, 17 Feb 2017 23:43:53 +0100
Message-ID: <20170217224353.GP6096@lunn.ch>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
 <c45b44987d24c7aae83c796a3731295317ae83f7.1487365317.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: Pavel Belous <Pavel.Belous@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44163 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964822AbdBQXKR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 18:10:17 -0500
Content-Disposition: inline
In-Reply-To: <c45b44987d24c7aae83c796a3731295317ae83f7.1487365317.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
> index 4c40644..0877625 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
> @@ -278,6 +278,8 @@ int aq_ring_rx_fill(struct aq_ring_s *self)
>  	struct aq_ring_buff_s *buff = NULL;
>  	int err = 0;
>  	int i = 0;
> +	unsigned int pages_order = fls(AQ_CFG_RX_FRAME_MAX / PAGE_SIZE +
> +		(AQ_CFG_RX_FRAME_MAX % PAGE_SIZE ? 1 : 0)) - 1;

Reverse Christmas tree?

	Andrew
