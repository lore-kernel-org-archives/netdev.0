From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 10/10] net: stmmac: dwmac-sun8i: Handle
 integrated/external MDIOs
Date: Fri, 8 Sep 2017 16:17:36 +0200
Message-ID: <20170908141736.GF25219@lunn.ch>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-11-clabbe.montjoie@gmail.com>
 <20170908130520.GA11248@lunn.ch>
 <20170908132632.GA3037@Red>
 <20170908140020.GC25219@lunn.ch>
 <20170908140832.GB3037@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170908140832.GB3037@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Do you know why the reset times out/fails?
> > 
> 
> Because there are nothing connected to it.

That should not be an issue. A read should just return 0xffff.  And it
should return 0xffff fast. The timing of the MDIO protocol is fixed. A
read or a write takes a fixed number of cycles, independent of if
there is a device there or not. The bus data line has a pullup, so if
you try to access a missing device, you automatically read 0xffff.

       Andrew
