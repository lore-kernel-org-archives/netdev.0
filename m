From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for sun8i-h3-emac
Date: Mon, 21 Aug 2017 16:10:17 +0800
Message-ID: <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
 <20170818122118.4925-4-clabbe.montjoie@gmail.com> <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
 <20170819185025.GB13266@Red> <20170819203836.GA21567@lunn.ch>
 <20170820065757.GA6081@Red> <20170820142545.GB24150@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170820142545.GB24150@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 20, 2017 at 10:25 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> I think we cannot use mdio-mux-mmioreg since the register for doing
>> the switch is in middle of the "System Control" and shared with
>> other functions.  This is why we use a sycon/regmap for selecting
>> the MDIO.
>
> You could add a mdio-mux-regmap.c.
>
> However, it probably need restructuring of the stmmac mdio code, to
> make the mdio bus usable as a separate driver. You need stmmac mdio
> to probe first, then mdio-mux-remap should probe, and then lastly
> stmmmac mac driver.
>
> With stmmac mdio and stmmac mac being in one driver, there is no time
> in the middle to allow the mux driver to probe.
>
> It is some effort, but a nice cleanup and generalization.

I'm not sure mdio-mux is the right thing here.

Looking at mdio-mux, it seems to provide a way to access multiplexed
MDIO buses. It says nothing about the MAC<->PHY connection.

With our hardware, and likely Rockchip's as well, the muxed connections
include the MDIO and MII connections, which are muxed at the same time.
It's likely to cause some confusion or even bugs if we implement it as
a separate driver.

ChenYu
