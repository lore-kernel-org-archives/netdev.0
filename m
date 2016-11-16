From: Jerome Brunet <jbrunet@baylibre.com>
Subject: Re: [PATCH net 1/3] net: phy: realtek: add eee advertisement
 disable options
Date: Wed, 16 Nov 2016 10:56:29 +0100
Message-ID: <1479290189.17538.25.camel@baylibre.com>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
         <1479220154-25851-2-git-send-email-jbrunet@baylibre.com>
         <20161115163036.GB23231@lunn.ch>
         <476b72f3-5efe-3551-6c24-0e378d655a0f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37845 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753617AbcKPJ4c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 04:56:32 -0500
Received: by mail-wm0-f52.google.com with SMTP id t79so60807046wmt.0
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 01:56:31 -0800 (PST)
In-Reply-To: <476b72f3-5efe-3551-6c24-0e378d655a0f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-15 at 09:03 -0800, Florian Fainelli wrote:
> On 11/15/2016 08:30 AM, Andrew Lunn wrote:
> > 
> > On Tue, Nov 15, 2016 at 03:29:12PM +0100, Jerome Brunet wrote:
> > > 
> > > On some platforms, energy efficient ethernet with rtl8211 devices
> > > is
> > > causing issue, like throughput drop or broken link.
> > > 
> > > This was reported on the OdroidC2 (DWMAC + RTL8211F). While the
> > > issue root
> > > cause is not fully understood yet, disabling EEE advertisement
> > > prevent auto
> > > negotiation from enabling EEE.
> > > 
> > > This patch provides options to disable 1000T and 100TX EEE
> > > advertisement
> > > individually for the realtek phys supporting this feature.
> > 
> > Looking at the code, i don't see anything specific to RealTek
> > here. This all seems generic. So should it be in phy.c and made a
> > generic OF property which can be applied to any PHY which supports
> > EEE.
> 
> Agreed.

Good point, Thanks for pointing this out.

> Just to be sure, Jerome, you did verify that with EEE no longer
> advertised, ethtool --set-eee fails, right? The point is that you may
> be
> able to disable EEE on boot, but if there is a way to re-enable it
> later
> on, we would want to disable that too.

I was focused on getting the issue out of way I did not think that
someone could try something like this :)
I just tried and it is possible to re-enable eee, though it is not
simplest thing to do: using ethtool enable eee advertisement, enable
eee, restart the autonegotiation without bringing the interface down
(otherwise the phy config kicks and disable eee again). I reckon this
is not good and I need to address this.

There two kind of PHYs supporting eee, the one advertising eee by
default (like realtek) and the one not advertising it (like micrel).
If the property is going to be generic, I see two options and I'd like
your view on this:

1) The DT provided value could be seen as "preferred" (or boot
setting), which can be cleanly changed with ethtool later on. In this
case, I guess I need to provide a way to force eee advertisement as
well to be consistent.

2) The DT provided value could forbid the advertisement of eee. In this
case I need to return an error if ethtool tries to re-enable it. Phy
with eee advertisement off by default (and not forbidden) would still
need to activate it manually with ethtool after boot. I don't see why
someone would absolutely want eee activated at boot time so I guess
this is OK.

Do you have a preference ?

Thanks for this quick feedback !
Cheers

Jerome
