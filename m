From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH net-next v2 3/4] Documentation: net: phy: Add blurb about
 RGMII
Date: Sun, 27 Nov 2016 16:24:59 -0600
Message-ID: <583B5D3B.4040108@codeaurora.org>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
 <20161127184449.12351-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        jbrunet@baylibre.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34474 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751230AbcK0WZD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 17:25:03 -0500
In-Reply-To: <20161127184449.12351-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just some grammatical corrections.  You might want to run a spellchecker 
on all the patches.

Florian Fainelli wrote:
> + The Reduced Gigabit Medium Independent Interface (RGMII) is a 12 pins

"is a 12-pin"

> + electrical signal interface using a synchronous 125Mhz clock signal and several
> + data lines. Due to this design decision, a 1.5ns to 2ns delay must be added
> + between the clock line (RXC or TXC) and the data lines to let the PHY (clock
> + sink) have enough setup and hold times to sample the data lines correctly. The
> + PHY library offers different types of PHY_INTERFACE_MODE_RGMII* values to let
> + the PHY driver and optionaly the MAC driver implement the required delay. The

"driver, and optionally the MAC driver, implement"

> + values of phy_interface_t must be understood from the perspective of the PHY
> + device itself, leading to the following:
> +
> + * PHY_INTERFACE_MODE_RGMII: the PHY is not responsible for inserting any
> +   internal delay by itself, it assumes that either the Ethernet MAC (if capable
> +   or the PCB traces) insert the correct 1.5-2ns delay
> +
> + * PHY_INTERFACE_MODE_RGMII_TXID: the PHY should be inserting an internal delay

"should insert"


> +   for the transmit data lines (TXD[3:0]) processed by the PHY device
> +
> + * PHY_INTERFACE_MODE_RGMII_RXID: the PHY should be inserting an internal delay

"should insert"


> +   for the receive data lines (RXD[3:0]) processed by the PHY device
> +
> + * PHY_INTERFACE_MODE_RGMII_ID: the PHY should be inserting internal delays for

"should insert"

> +   both transmit AND receive data lines from/to the PHY device
> +
> + Whenever it is possible, it is preferrable to utilize the PHY side RGMII delay
> + for several reasons:

"Whenever possible, use the PHY side RGMII delay for these reasons:"

> + * PHY devices may offer sub-nanosecond granularity in how they allow a
> +   receiver/transmitter side delay (e.g: 0.5, 1.0, 1.5ns) to be specified. Such
> +   precision may be required to account for differences in PCB trace lengths
> +
> + * PHY devices are typically qualified for a large range of applications
> +   (industrial, medical, automotive...), and they provide a constant and
> +   reliable delay across temperature/pressure/voltage ranges
> +
> + * PHY device drivers in PHYLIB being reusable by nature, being able to
> +   configure correctly a specified delay enables more designs with similar delay
> +   requirements to be operate correctly

Ok, this one I don't know how to fix.  I'm not really sure what you're 
trying to say.

> +
> + For cases where the PHY is not capable of providing this delay, but the
> + Ethernet MAC driver is capable of doing it, the correct phy_interface_t value

"doing so,"

> + should be PHY_INTERFACE_MODE_RGMII, and the Ethernet MAC driver should be
> + configured correctly in order to provide the required transmit and/or receive
> + side delay from the perspective of the PHY device. Conversely, if the Ethernet
> + MAC driver looks at the phy_interface_t value, for any other mode but
> + PHY_INTERFACE_MODE_RGMII, it should make sure that the MAC-level delays are
> + disabled.
> +
> + In case neither the Ethernet MAC, nor the PHY are capable of providing the
> + required delays, as defined per the RGMII standard, several options may be
> + available:
> +
> + * Some SoCs may offer a pin pad/mux/controller capable of configuring a given
> +   set of pins' drive strength, delays and voltage, and it may be a suitable

"strength, delays, and voltage; and"

> +   option to insert the expected 2ns RGMII delay
> +
> + * Modifying the PCB design to include a fixed delay (e.g: using a specifically
> +   designed serpentine), which may not require software configuration at all

period after "all".

> +
> +Common problems with RGMII delay mismatch
> +
> + When there is a RGMII delay mismatch between the Ethernet MAC and the PHY, this
> + will most likely result in the clock and data line sampling to capture unstable

I'm not sure what "sampling to capture unstable" is supposed to mean.

> + signals, typical symptoms include:
> +
> + * Transmission/reception partially works, and there is frequent or occasional
> +   packet loss observed
> +
> + * Ethernet MAC may report some, or all packets ingressing with a FCS/CRC error,

No comma after "some".

> +   or just discard them all
> +
> + * Switching to lower speeds such as 10/100Mbits/sec makes the problem go away
> +   (since there is enough setup/hold time in that case)

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
