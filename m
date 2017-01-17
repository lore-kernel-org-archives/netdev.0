From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] net: ethernet: stmmac: add ARP management
Date: Wed, 18 Jan 2017 01:14:08 +0200
Message-ID: <CAHp75VfomowHQis_Yo9dEp9KY-i7yB0SvyKeMGvEnvK_ocGrQw@mail.gmail.com>
References: <1484672200-7755-1-git-send-email-christophe.roullier@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Christophe Roullier <christophe.roullier@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35226 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdAQXOP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 18:14:15 -0500
In-Reply-To: <1484672200-7755-1-git-send-email-christophe.roullier@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 6:56 PM, Christophe Roullier
<christophe.roullier@st.com> wrote:

> +static int dwmac4_arp_enable(struct mac_device_info *hw)
> +{
> +       void __iomem *ioaddr = hw->pcsr;

__iomem *config = hw->pcsr + GMAC_CONFIG;

> +       u32 value = readl(ioaddr + GMAC_CONFIG);
> +
> +       value |= GMAC_CONFIG_ARPEN;
> +
> +       writel(value, ioaddr + GMAC_CONFIG);

u32 value;

value = readl();
writel(value | ...);

?

> +
> +       value = readl(ioaddr + GMAC_CONFIG);
> +
> +       return !!(value & GMAC_CONFIG_ARPEN);
> +}

> +/* Set ARP Address */
> +static void dwmac4_set_arp_addr(void __iomem *ioaddr, bool set, u32 addr)
> +{

__iomem *arp_addr = ioaddr + GMAC_ARP_ADDR;

> +       u32 value;
> +
> +       value = readl(ioaddr + GMAC_ARP_ADDR);

Care to explain why do you need dummy readl() here?

> +
> +       if (set) {
> +               /* set arp address */
> +               value = addr;
> +       } else {
> +               /* unset arp address */
> +               value = 0;
> +       }

value = set ? addr : 0;


> +
> +       writel(value, ioaddr + GMAC_ARP_ADDR);
> +       value = readl(ioaddr + GMAC_ARP_ADDR);
> +}


> +       if ((priv->plat->arp_en) && (priv->dma_cap.arpoffsel)) {
> +               ret = priv->hw->mac->arp_en(priv->hw);
> +               if (!ret) {

Hmm... Most would expect

if (ret) {
 doing something
} else {
 doing something else
}

> +                       pr_warn(" ARP feature disabled\n");
> +               } else {

> +                       pr_info(" ARP feature enabled\n");

Wouldn't be too noisy?

pr_* -> dev_*

> +                       /* Copy MAC addr into MAC_ARP_ADDRESS register*/
> +                       priv->hw->dma->set_arp_addr(priv->ioaddr, 1,
> +                                                   priv->dev->dev_addr);
> +               }
> +       }

-- 
With Best Regards,
Andy Shevchenko
