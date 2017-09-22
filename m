From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/ncsi: Don't assume last available channel
 exists
Date: Thu, 21 Sep 2017 18:11:11 -0700 (PDT)
Message-ID: <20170921.181111.2086501653519863373.davem@davemloft.net>
References: <20170920041251.14635-1-sam@mendozajonas.com>
        <20170920.160519.764603868579556859.davem@davemloft.net>
        <1506042000.1377.21.camel@mendozajonas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sam@mendozajonas.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506042000.1377.21.camel@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Date: Fri, 22 Sep 2017 11:00:00 +1000

> If we haven't configured a channel yet (or are in the process of doing
> so) we won't have a hot_channel - does it make more sense to
> - check against the hot_channel as currently done,
> - only check the filter size at configure time for /each/ channel,
> - only conditionally enable the .ndo_vlan_rx_add_vid net_device callback
> once we've configured a channel (eg. for ftgmac100 in the
> ftgmac100_ncsi_handler() callback?)

The last isn't so feasible.

The device shouldn't be marked attached until a channel is available,
because it seems like communication cannot occur until one is.  Right?

You could experiment with netif_device_detach()/netif_device_attach().

When the device is in the detached state, callbacks such as
->ndo_vlan_rx_add_vid() will not be invoked.
