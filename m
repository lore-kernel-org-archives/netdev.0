From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [Patch RFC net-next] net: usb: r8152: Fix rx_bytes/tx_bytes to
 include FCS
Date: Thu, 18 May 2017 17:09:25 +0200
Message-ID: <20170518150925.GB707@lunn.ch>
References: <1495052615-14360-1-git-send-email-andrew@lunn.ch>
 <286d107e-2380-f8e9-3edf-c949707ea235@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        hayeswang <hayeswang@realtek.com>,
        Mario Limonciello <mario_limonciello@dell.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35652 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932227AbdERPJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 11:09:29 -0400
Content-Disposition: inline
In-Reply-To: <286d107e-2380-f8e9-3edf-c949707ea235@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I am afraid that we won't be able to enforce a consistent behavior,
> because the HW itself is not consistent, both on the NIC and on the
> switch side.

Hi Florian

I agree with that, for MIB counters. They tend to come direct from the
hardware.

However, rx_bytes and tx_bytes are not from the hardware. They are
software stats, kept by the drivers. Just grep in driver/net/ethernet
and you see:

broadcom/bcmsysport.c:		        ndev->stats.rx_bytes += len;
broadcom/sb1250-mac.c:			dev->stats.rx_bytes += len;
mellanox/mlx5/core/en_main.c:		s->rx_bytes	+= rq_stats->bytes;
microchip/encx24j600.c:			dev->stats.rx_bytes += rsv->len;
neterion/vxge/vxge-main.c:		net_stats->rx_bytes += bytes;
nuvoton/w90p910_ether.c:		dev->stats.rx_bytes += length;

etc.

Since these are software counters, they can be consistent. From a
practical point of view, i doubt they ever will all be consistent,
there are simply too many drivers to test and change if
needed. However, for the ones somebody cares about, they can be made
consistent.

I care about r8152, and would like to make it consistent with asix,
dsa, e1000e.

     Andrew
