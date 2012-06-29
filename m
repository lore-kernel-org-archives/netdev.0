From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 4/4 (v9)] phy: add the EEE support and the way to
 access to the MMD registers.
Date: Fri, 29 Jun 2012 18:36:03 +0100
Message-ID: <1340991363.3066.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340867678-18375-1-git-send-email-peppe.cavallaro@st.com>
	 <1340867678-18375-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<rayagond@vayavyalabs.com>, <davem@davemloft.net>,
	<yuvalmin@broadcom.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63338 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755819Ab2F2RgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 13:36:07 -0400
In-Reply-To: <1340867678-18375-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-28 at 09:14 +0200, Giuseppe CAVALLARO wrote:
> This patch adds the support for the Energy-Efficient Ethernet (EEE)
> to the Physical Abstraction Layer.
> To support the EEE we have to access to the MMD registers 3.20 and
> 7.60/61. So two new functions have been added to read/write the MMD
> registers (clause 45).
> 
> An Ethernet driver (I tested the stmmac) can invoke the phy_init_eee to properly
> check if the EEE is supported by the PHYs and it can also set the clock
> stop enable bit in the 3.0 register.
> The phy_get_eee_err can be used for reporting the number of time where
> the PHY failed to complete its normal wake sequence.
> 
> In the end, this patch also adds the EEE ethtool support implementing:
>  o phy_ethtool_set_eee
>  o phy_ethtool_get_eee
> 
> v1: initial patch
> v2: fixed some errors especially on naming convention
> v3: renamed again the mmd read/write functions thank to Ben's feedback
> v4: moved file to phy.c and added the ethtool support.
> v5: fixed phy_adv_to_eee, phy_eee_to_supported, phy_eee_to_adv return
>     values according to ethtool API (thanks to Ben's feedback).
>     Renamed some macros to avoid too long names.
> v6: fixed kernel-doc comments to be properly parsed.
>     Fixed the phy_init_eee function: we need to check which link mode
>     was autonegotiated and then the corresponding bits in 7.60 and 7.61
>     registers.
> v7: reviewed the way to get the negotiated settings.
> v8: fixed a problem in the phy_init_eee return value erroneously added
>     when included the phy_read_status call.
> v9: do not remove the MDIO_AN_EEE_ADV_100TX and MDIO_AN_EEE_ADV_1000T
>     and fixed the eee_{cap,lp,adv} declaration as "int" instead of u16.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
[...]
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

(but not tested in any way)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
