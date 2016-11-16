From: Jerome Brunet <jbrunet@baylibre.com>
Subject: Re: [PATCH net 1/3] net: phy: realtek: add eee advertisement
 disable options
Date: Wed, 16 Nov 2016 16:38:51 +0100
Message-ID: <1479310731.17538.53.camel@baylibre.com>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
         <1479220154-25851-2-git-send-email-jbrunet@baylibre.com>
         <20161115163036.GB23231@lunn.ch>
         <476b72f3-5efe-3551-6c24-0e378d655a0f@gmail.com>
         <1479290189.17538.25.camel@baylibre.com> <20161116132337.GD19962@lunn.ch>
         <1479307890.17538.40.camel@baylibre.com> <20161116150628.GI23231@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161116150628.GI23231@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-11-16 at 16:06 +0100, Andrew Lunn wrote:
> On Wed, Nov 16, 2016 at 03:51:30PM +0100, Jerome Brunet wrote:
> > 
> > On Wed, 2016-11-16 at 14:23 +0100, Andrew Lunn wrote:
> > > 
> > > > 
> > > > 
> > > > There two kind of PHYs supporting eee, the one advertising eee
> > > > by
> > > > default (like realtek) and the one not advertising it (like
> > > > micrel).
> > 
> > This is just the default register value.
> > 
> > > 
> > > 
> > > I don't know too much about EEE. So maybe a dumb question. Does
> > > the
> > > MAC need to be involved? Or is it just the PHY?
> > > 
> > > If the MAC needs to be involved, the PHY should not be
> > > advertising
> > > EEE
> > > unless the MAC asks for it by calling phy_init_eee(). If this is
> > > true,
> > > maybe we need to change the realtek driver, and others in that
> > > class.
> > 
> > As far I understand, the advertised capabilities are exchanged
> > during
> > the auto-negotiation.
> > 
> > At this stage, if the advertisement is disabled (regarless of the
> > actual support) on either side of the link, there will be no low
> > power
> > idle state on the Tx nor the Rx path.
> > 
> > If the advertisement is enabled on both side but we don't call
> > phy_init_eee, I suppose Tx won't enter LPI, but Rx could.
> 
> What i was trying to find out is, if the MAC needs to support EEE as
> well as the PHY, what happens when the MAC does not support EEE, but
> the PHYs do negotiate EEE? Does it break?

Interesting question. In a regular case, I suppose it should be fine.
As you would have LPI only on the Rx path this should be transparent to
the MAC. That's my understanding. Maybe people knowing EEE better than
me could confirm (or not) ? Peppe? Alexandre?

I just checked with the OdroidC2, I disabled eee support by forcing
"dma_cap.eee = 0" in stmmac_get_hw_features. As expected, no tx_LPI
interrupts but plenty of rx_LPI interrupts.

What was not expected is test failing like before.
So in our case, having LPI on the Rx path is fine for receiving data,
but not for sending.

> 
>     Andrew
