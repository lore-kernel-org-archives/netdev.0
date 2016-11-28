From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH ethtool 2/2] Ethtool: Implements PHY Loopback
Date: Mon, 28 Nov 2016 09:56:04 -0800
Message-ID: <73aa42bc-b476-ba5a-cf22-115b409a40e3@gmail.com>
References: <1480339512-5882-1-git-send-email-allan.nielsen@microsemi.com>
 <1480339512-5882-3-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linville@tuxdriver.com, andrew@lunn.ch,
        raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34760 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbcK1R4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:56:07 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so6820284pfb.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:56:07 -0800 (PST)
In-Reply-To: <1480339512-5882-3-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 05:25 AM, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Add loopback in ethtool tunables to access PHY drivers.
> 
> Ethtool Help: ethtool -h for PHY tunables
>     ethtool --set-phy-tunable DEVNAME      Set PHY tunable
>                 [ loopback off|near|far|extn ]
>     ethtool --get-phy-tunable DEVNAME      Get PHY tunable
>                 [ loopback ]
> 
> Ethtool ex:
>   ethtool --set-phy-tunable eth0 loopback near
>   ethtool --set-phy-tunable eth0 loopback far
>   ethtool --set-phy-tunable eth0 loopback extn
>   ethtool --set-phy-tunable eth0 loopback off
> 
>   ethtool --get-phy-tunable eth0 loopback
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
> ---

> +Near-End Loopback:
> +Transmitted data (TXD) is looped back in the PCS block onto the receive data
> +signal (RXD). When Near-End loopback enable, no data is transmitted over
> +the network. no data receive from the network.

This is also known as the local loopback test mode, right?

> +
> +Far-End Loopback:
> +This loopback is a special test mode to allow testing the PHY from link
> +partner side. In this mode data that is received from the link partner pass
> +through the PHY's receiver, looped back on the MII and transmitted back to
> +the link partner.

And this is the remote loopback mode.


> +
> +External Loopback:
> +An RJ45 loopback cable can be used to route the transmit signals an the
> +output of the trnsformer back to the receiver inputs and this loopback will
> +work at either 10 or 100 or 1000 Mbps speed.
> +RJ45 Loopback cable created by conncting pin 1 to pin 3 and connecting pin
> +2 to pin 6.

OK, this name makes sense to me, but for the two other names, we need to
use a terminology that is clearer to the reader and/or people familiar
and targeted at using this feature (e.g: in a lab or during manufacturing).
-- 
Florian
