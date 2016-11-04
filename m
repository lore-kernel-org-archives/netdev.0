From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH ethtool 2/2] Ethtool: Implements
 ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY downshift
Date: Fri, 4 Nov 2016 12:59:37 +0100
Message-ID: <20161104115937.GH13959@lunn.ch>
References: <1478255805-25823-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255805-25823-3-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com, cphealy@gmail.com, robh@kernel.org
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36793 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933105AbcKDL7l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 07:59:41 -0400
Content-Disposition: inline
In-Reply-To: <1478255805-25823-3-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Allen

> +++ b/ethtool.8.in
> @@ -340,6 +340,14 @@ ethtool \- query or control network driver and hardware settings
>  .B2 tx-lpi on off
>  .BN tx-timer
>  .BN advertise
> +.HP
> +.B ethtool \-\-set\-phy\-tunable
> +.I devname
> +.B3 downshift on off N
> +.HP

I don't think there is any other option which is on|off|N. The general
pattern would be

--set-phy-tunable downshift on|off [count N]

With count being optional.

This also allows avoiding the ambiguity of what

--set-phy-tunable downshift 0

means. To me, that means downshift after 0 retries. But it actually
seems to mean never downshift. You can then error out when somebody
does

--set-phy-tunable downshift on count 0
or
--set-phy-tunable downshift off count 42

Please also add a few sentences about what downshift is, and what N
means. Is it tries, or retries?

Thanks
       Andrew
