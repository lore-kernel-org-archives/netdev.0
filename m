From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 4/4 (v8)] phy: add the EEE support and the way
 to access to the MMD registers.
Date: Thu, 28 Jun 2012 08:54:44 +0200
Message-ID: <4FEBFFB4.7080605@st.com>
References: <1340258599-3083-1-git-send-email-peppe.cavallaro@st.com>  <1340258599-3083-5-git-send-email-peppe.cavallaro@st.com> <1340813737.2591.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rayagond@vayavyalabs.com, davem@davemloft.net,
	yuvalmin@broadcom.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:33298 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932325Ab2F1GzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 02:55:22 -0400
In-Reply-To: <1340813737.2591.5.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/27/2012 6:15 PM, Ben Hutchings wrote:
> On Thu, 2012-06-21 at 08:03 +0200, Giuseppe CAVALLARO wrote:
> [...]
>> v8: fixed a problem in the phy_init_eee return value erroneously added
>>     when included the phy_read_status call.
> 
> Almost there. :-/

no problem :-)

> [...]
>> +int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
>> +{
>> +	int ret = -EPROTONOSUPPORT;
>> +
>> +	/* According to 802.3az,the EEE is supported only in full duplex-mode.
>> +	 * Also EEE feature is active when core is operating with MII, GMII
>> +	 * or RGMII.
>> +	 */
>> +	if ((phydev->duplex == DUPLEX_FULL) &&
>> +	    ((phydev->interface == PHY_INTERFACE_MODE_MII) ||
>> +	    (phydev->interface == PHY_INTERFACE_MODE_GMII) ||
>> +	    (phydev->interface == PHY_INTERFACE_MODE_RGMII))) {
>> +		u16 eee_lp, eee_cap, eee_adv;
>> +		u32 lp, cap, adv;
>> +		int idx, status;

[snip]

>> +
>> +		eee_adv = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV,
>> +						MDIO_MMD_AN, phydev->addr);
>> +		if (eee_adv < 0)
>> +			return eee_adv;
> 
> You check for eee_{cap,lp,adv} < 0 but that's impossible since the
> variables are declared unsigned (u16).  (I wonder what compiler you are
> using, as I would expect this to result in a warning.)  I think they
> need to be declared int.

IIRC I have compiled w/ no warnings (on arm  and sh4 -- gcc 4.6.3) but
you are right and I'll fix that, no problem at all.

[snip]

>> +			u32 val = phy_read_mmd_indirect(phydev->bus, MDIO_CTRL1,
>> +							MDIO_MMD_PCS,
>> +							phydev->addr);
>> +			if (val < 0)
>> +				return val;
> 
> Same problem here.

yes

> 
> [...]
>> --- a/include/linux/mdio.h
>> +++ b/include/linux/mdio.h
> [...]
>> @@ -237,9 +241,18 @@
>>  #define MDIO_AN_10GBT_STAT_MS		0x4000	/* Master/slave config */
>>  #define MDIO_AN_10GBT_STAT_MSFLT	0x8000	/* Master/slave config fault */
>>  
>> -/* AN EEE Advertisement register. */
>> -#define MDIO_AN_EEE_ADV_100TX		0x0002	/* Advertise 100TX EEE cap */
>> -#define MDIO_AN_EEE_ADV_1000T		0x0004	/* Advertise 1000T EEE cap */
> [...]
> 
> This header is exported to userland so I don't think these definitions
> can be removed.  But you could comment that they're redundant with the
> following MDIO_EEE_* definitions.

Indeed I agree with you and I've already fixed this w/o removing them.
I'm sending the new patches now.

Thanks again for your feedback and help.

Peppe

> 
> Ben.
> 
