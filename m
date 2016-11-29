From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 3/4] Documentation: net: phy: Add blurb
 about RGMII
Date: Tue, 29 Nov 2016 13:47:53 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB022CC81@AcuExch.aculab.com>
References: <20161128024515.13070-1-f.fainelli@gmail.com>
 <20161128024515.13070-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "sf84@laposte.net" <sf84@laposte.net>,
        "martin.blumenstingl@googlemail.com"
        <martin.blumenstingl@googlemail.com>,
        "mans@mansr.com" <mans@mansr.com>,
        "alexandre.torgue@st.com" <alexandre.torgue@st.com>,
        "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
        "timur@codeaurora.org" <timur@codeaurora.org>,
        "jbrunet@baylibre.com" <jbrunet@baylibre.com>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:53954 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757513AbcK2NsB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 08:48:01 -0500
In-Reply-To: <20161128024515.13070-4-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli
> Sent: 28 November 2016 02:45
> RGMII is a recurring source of pain for people with Gigabit Ethernet
> hardware since it may require PHY driver and MAC driver level
> configuration hints. Document what are the expectations from PHYLIB and
> what options exist.
...
> + * PHY_INTERFACE_MODE_RGMII_TXID: the PHY should insert an internal delay
> +   for the transmit data lines (TXD[3:0]) processed by the PHY device
> +
> + * PHY_INTERFACE_MODE_RGMII_RXID: the PHY should insert an internal delay
> +   for the receive data lines (RXD[3:0]) processed by the PHY device

These delays are subtly different, so the texts shouldn't really be the same.
I think the clock is delayed before latching the TX data and the RX data gets
delayed from the clock.

...
> + * Switching to lower speeds such as 10/100Mbits/sec makes the problem go away
> +   (since there is enough setup/hold time in that case)

The setup/hold times aren't directly affected by the lower speed.
So something else is going on.
Possibly the data is changed on one edge and sampled on the other at lower
speeds, but changes every clock edge at 1Gb.

	David
