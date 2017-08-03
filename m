From: "David.Wu" <david.wu@rock-chips.com>
Subject: Re: [PATCH v3 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Thu, 3 Aug 2017 22:02:53 +0800
Message-ID: <6cf4697e-7e94-0e14-a059-c80053492da3@rock-chips.com>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
 <1501654888-19514-1-git-send-email-david.wu@rock-chips.com>
 <6b1ebf64-6903-6d35-b1fc-92ec47334425@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, wens@csie.org
To: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        heiko@sntech.de, andrew@lunn.ch, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucky1.263xmail.com ([211.157.147.133]:37931 "EHLO
        lucky1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdHCOCz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 10:02:55 -0400
In-Reply-To: <6b1ebf64-6903-6d35-b1fc-92ec47334425@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian & ChenYu

在 2017/8/3 1:38, Florian Fainelli 写道:
> This is incorrect in two ways:
> 
> - this is a property of the PHY, so it should be documented as such in
> Documentation/devicetree/bindings/net/phy.txt so other bindings can
> re-use it
> 
> - if it was specific to your MAC you would expect a vendor prefix to
> this property, which is not there
> 
> An alternative way to implement the external/internal logic selection
> would be mandate that your Ethernet PHY node have a compatible string
> like this:
> 
> phy@0 {
> 	compatible = "ethernet-phy-id1234.d400", "ethernet-phy-802.3-c22";
> };
> 
> Then you don't need this phy-is-internal property, because you can
> locate the PHY node by the phy-handle (see more about that in a reply to
> patch 10) and you can determine ahead of time whether this PHY is
> internal or not based on its compatible string.

We may implement a read_bool_property after parsed phy phandle at 
stmmac_platform.c, which would make MAC driver know it is a internal phy.
