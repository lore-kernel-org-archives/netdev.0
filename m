From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 1/4] net: dt-bindings: Document the new Meson8b and GXBB DWMAC bindings
Date: Mon, 22 Aug 2016 17:25:30 +0200
Message-ID: <4041259.IszN4229Cj@wuerfel>
References: <20160815164100.27766-1-martin.blumenstingl@googlemail.com> <7308700.atIMKyMFZU@wuerfel> <CAFBinCA0HWHR3UbVX-_wU14W0-KOr-BAf5Nyn1ocZdnYxojn2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        mark.rutland@arm.com, devicetree@vger.kernel.org,
        sboyd@codeaurora.org, catalin.marinas@arm.com,
        alexandre.torgue@st.com, khilman@baylibre.com,
        mturquette@baylibre.com, will.deacon@arm.com, robh+dt@kernel.org,
        peppe.cavallaro@st.com, carlo@caione.org,
        linux-amlogic@lists.infradead.org, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:61923 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753243AbcHVP05 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 11:26:57 -0400
In-Reply-To: <CAFBinCA0HWHR3UbVX-_wU14W0-KOr-BAf5Nyn1ocZdnYxojn2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, August 22, 2016 2:04:49 PM CEST Martin Blumenstingl wrote:
> On Mon, Aug 22, 2016 at 1:55 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Saturday, August 20, 2016 11:35:35 AM CEST Martin Blumenstingl wrote:
> >> +- reg: The first register range should be the one of the DWMAC
> >> +       controller. The second range is is for the Amlogic specific
> >> +       configuration (for example the PRG_ETHERNET register range
> >> +       on Meson8b and newer)
> >>
> > ...
> >
> >> +Example for GXBB:
> >> +       ethmac: ethernet@c9410000 {
> >> +               compatible = "amlogic,meson-gxbb-dwmac", "snps,dwmac";
> >> +               reg = <0x0 0xc9410000 0x0 0x10000>,
> >> +                       <0x0 0xc8834540 0x0 0x8>;
> >>
> >
> > The address "0xc8834540" suggests that this is part of a larger register
> > range that is used for various things, i.e. a "syscon" type of device.
> You are right, these are part of the cbus range (which is already
> defined in meson-gxbb.dtsi)
> 
> > How about making this a syscon reference rather than a "reg" address?
> The first version of my patch ([0]) used
> syscon_regmap_lookup_by_phandle. Maybe I did it wrong (and I should
> have passed the cbus syscon-node instead of defining a new one just
> for the 2x32bit PRG_ETHERNET registers).
> I am perfectly fine with either way - however it seems that some other
> dwmac glue implementations are also using a second set of resources
> (that doesn't automatically make it "correct" though).

It really depends on the kind of SoC. Some may have a suboptimal
binding, on some others there may be a distinct register area that
just contains a few additional registers for the dwmac.

	Arnd
