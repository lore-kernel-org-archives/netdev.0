From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: ethernet: stmmac: properly set PS bit in MII
 configurations during reset
Date: Mon, 8 May 2017 21:12:30 +0200
Message-ID: <20170508211230.58aeead9@free-electrons.com>
References: <1493286329-24448-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <deea272a-f0a9-ad0b-4ad6-387723938314@st.com>
        <20170503143032.GA22106@Red>
        <49297ed2-84dc-3e9b-8f40-af915476a091@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <49297ed2-84dc-3e9b-8f40-af915476a091@st.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, 8 May 2017 16:28:21 +0200, Giuseppe CAVALLARO wrote:

> > I just see that GMAC_CONTROL and MAC_CTRL_REG are the same, so why not create a custom adjust_link for each dwmac type ?
> > This will permit to call it instead of set_ps() and remove lots of if (has_gmac) and co in stmmac_adjust_link()
> > Basicly replace all between "ctrl = readl()... and writel(ctrl)" by a sot of priv->hw->mac->adjust_link()
> >
> > It will also help a lot for my dwmac-sun8i inclusion (since I add some if has_sun8i:))  
> 
> Corentin, I think this is a good idea and maybe necessary now that the 
> driver is supporting a lot of chips.
> In the past it was sufficient to have a adjust link function and a 
> stmmac_hw_fix_mac_speed
> to invoke dedicated hook shared between MAC10/100 and GMAC inside STM 
> platforms.
> 
> Thomas, I wonder if you could take a look at the 
> priv->plat->fix_mac_speed. This can be used
> for setting internal registers too.

Once again, this is not called at the right time to fix the issue I'm
seeing with a MII PHY. I need to adjust the PS bit between asserting the
reset and polling for the reset bit to clear.

->fix_mac_speed() is called in the adjust_link() call-back, which is
called way too late.

Please, read again my patch and the description of the problem that I
have sent. But basically, any solution that does not allow to set the
PS bit between asserting the DMA reset bit and polling for it to clear
will not work for MII PHYs.

Best regards,

Thomas Petazzoni
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
