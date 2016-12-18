From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 2/2] net: stmmac: dwmac-meson8b: make the
 RGMII TX delay configurable
Date: Sun, 18 Dec 2016 10:49:50 -0500 (EST)
Message-ID: <20161218.104950.1013829528388480468.davem@davemloft.net>
References: <20161202233238.17561-1-martin.blumenstingl@googlemail.com>
        <20161217182119.4037-1-martin.blumenstingl@googlemail.com>
        <20161217182119.4037-3-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-amlogic@lists.infradead.org, robh+dt@kernel.org,
        mark.rutland@arm.com, carlo@caione.org, khilman@baylibre.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        linux-arm-kernel@lists.infradead.org
To: martin.blumenstingl@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55580 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753901AbcLRPtx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 10:49:53 -0500
In-Reply-To: <20161217182119.4037-3-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Date: Sat, 17 Dec 2016 19:21:19 +0100

> Prior to this patch we were using a hardcoded RGMII TX clock delay of
> 2ns (= 1/4 cycle of the 125MHz RGMII TX clock). This value works for
> many boards, but unfortunately not for all (due to the way the actual
> circuit is designed, sometimes because the TX delay is enabled in the
> PHY, etc.). Making the TX delay on the MAC side configurable allows us
> to support all possible hardware combinations.
> 
> This allows fixing a compatibility issue on some boards, where the
> RTL8211F PHY is configured to generate the TX delay. We can now turn
> off the TX delay in the MAC, because otherwise we would be applying the
> delay twice (which results in non-working TX traffic).
> 
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
> Tested-by: Neil Armstrong <narmstrong@baylibre.com>

Is this really the safest thing to do?

If you say the existing hard-coded setting of 1/4 cycle works on most
boards, and what you're trying to do is override it with an OF
property value for boards where the existing setting does not work,
then you _must_ use a default value that corresponds to what the
existing code does not when you don't see this new OF property.

So please retain the current behavior of the 1/4 cycle TX delay
setting when you don't see the amlogic,tx-delay-ns property.

I really think you risk breaking existing boards by not doing so,
unless you can have this patch tested on every such board that exists
and I don't think you really can feasibly and rigorously do that.

Thanks.
