From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH 3/3] net: stmmac: stmmac_platform: use correct
 setup function for gmac4
Date: Thu, 08 Dec 2016 11:36:02 -0500 (EST)
Message-ID: <20161208.113602.193796703301981430.davem@davemloft.net>
References: <1481114469-4788-1-git-send-email-niklass@axis.com>
        <1481114469-4788-3-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, niklass@axis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34172 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753709AbcLHQgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 11:36:25 -0500
In-Reply-To: <1481114469-4788-3-git-send-email-niklass@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Wed, 7 Dec 2016 13:41:08 +0100

> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> devicetree binding for stmmac states:
> - compatible: Should be "snps,dwmac-<ip_version>", "snps,dwmac"
> 	For backwards compatibility: "st,spear600-gmac" is also supported.
> 
> Previously, when specifying "snps,dwmac-4.10a", "snps,dwmac" as your
> compatible string, plat_stmmacenet_data would have both has_gmac and
> has_gmac4 set.
> 
> This would lead to stmmac_hw_init calling dwmac1000_setup rather than
> dwmac4_setup, resulting in a non-functional driver.
> This happened since the check for has_gmac is done before the check for
> has_gmac4. However, the order should not matter, so it does not make sense
> to have both set.
> 
> If something is valid for both, you should do as the stmmac_interrupt does:
> if (priv->plat->has_gmac || priv->plat->has_gmac4) ...
> 
> The places where it was obvious that the author actually meant
> if (has_gmac || has_gmac4) rather than if (has_gmac) has been updated.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> Acked-by: Alexandre TORGUE <alexandre.torgue@st.com>

Applied.
