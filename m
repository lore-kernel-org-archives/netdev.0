From: Dan Murphy <dmurphy@ti.com>
Subject: Re: [PATCH v5 1/2] net: phy: DP83822 initial driver submission
Date: Tue, 10 Oct 2017 14:05:47 -0500
Message-ID: <9bb50fe0-c14a-fdd5-0387-2a8bc2ce81be@ti.com>
References: <20171010174256.21930-1-dmurphy@ti.com>
 <9235D6609DB808459E95D78E17F2E43D40B48F9D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <afd@ti.com>
To: <Woojung.Huh@microchip.com>, <andrew@lunn.ch>,
        <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:56037 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932087AbdJJTGI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 15:06:08 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B48F9D@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian

On 10/10/2017 01:56 PM, Woojung.Huh@microchip.com wrote:
>> +static int dp83822_config_intr(struct phy_device *phydev)
>> +{
>> +	int misr_status;
>> +	int physcr_status;
>> +	int err;
>> +
>> +	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
>> +		misr_status = phy_read(phydev, MII_DP83822_MISR1);
>> +		if (misr_status < 0)
>> +			return misr_status;
>> +
>> +		misr_status |= (DP83822_RX_ERR_HF_INT_EN |
>> +				DP83822_FALSE_CARRIER_HF_INT_EN |
>> +				DP83822_ANEG_COMPLETE_INT_EN |
>> +				DP83822_DUP_MODE_CHANGE_INT_EN |
>> +				DP83822_SPEED_CHANGED_INT_EN |
>> +				DP83822_LINK_STAT_INT_EN |
>> +				DP83822_ENERGY_DET_INT_EN |
>> +				DP83822_LINK_QUAL_INT_EN);
>> +
>> +		err = phy_write(phydev, MII_DP83822_MISR1, misr_status);
>> +		if (err < 0)
>> +			return err;
>> +
>> +		misr_status = phy_read(phydev, MII_DP83822_MISR2);
>> +		if (misr_status < 0)
>> +			return misr_status;
>> +
>> +		misr_status |= (DP83822_JABBER_DET_INT_EN |
>> +				DP83822_WOL_PKT_INT_EN |
>> +				DP83822_SLEEP_MODE_INT_EN |
>> +				DP83822_MDI_XOVER_INT_EN |
>> +				DP83822_LB_FIFO_INT_EN |
>> +				DP83822_PAGE_RX_INT_EN |
>> +				DP83822_ANEG_ERR_INT_EN |
>> +				DP83822_EEE_ERROR_CHANGE_INT_EN);
>> +
>> +		err = phy_write(phydev, MII_DP83822_MISR2, misr_status);
>> +		if (err < 0)
>> +			return err;
>> +
>> +		physcr_status = phy_read(phydev, MII_DP83822_PHYSCR);
>> +		if (physcr_status < 0)
>> +			return physcr_status;
>> +
>> +		physcr_status |= DP83822_PHYSCR_INT_OE |
>> DP83822_PHYSCR_INTEN;
>> +
> Don't want to be picky, but seeing extra blank line here. 
> 

Let me know if you want me to fix this up.  Or if you will when you apply it.

Dan

<snip>


-- 
------------------
Dan Murphy
