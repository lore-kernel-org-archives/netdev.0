From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: [patch 0/1] Re: [patch 1/1] phy/marvell: fix 88e1121 support
Date: Tue, 19 Oct 2010 00:29:47 +0200
Message-ID: <20101018222947.418028323@rtp-net.org>
References: <20101018214401.053486146@rtp-net.org> <20101018214414.375368957@rtp-net.org>
 <4CBCC3FC.2030506@ti.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lechat.rtp-net.org ([88.191.19.38]:40953 "EHLO
	lechat.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932169Ab0JRWhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 18:37:20 -0400
In-Reply-To: <4CBCC3FC.2030506@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> @@ -199,13 +199,13 @@
>>  	mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
>>  		MII_88E1121_PHY_MSCR_DELAY_MASK;
>>  
>> -	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
>> -		mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
>> -			 MII_88E1121_PHY_MSCR_TX_DELAY);
>> -	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
>> +	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
>>  		mscr |= MII_88E1121_PHY_MSCR_RX_DELAY;
>>  	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
>>  		mscr |= MII_88E1121_PHY_MSCR_TX_DELAY;
>> +	else
>> +		mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
>> +			 MII_88E1121_PHY_MSCR_TX_DELAY);
>>  
>>  	err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
>>  	if (err < 0)
>
> This doesn't look right.  This change makes it impossible to configure
> the phy without interface delays, i.e., PHY_INTERFACE_MODE_RGMII ends up
> behaving the same as PHY_INTERFACE_MODE_RGMII_ID.
> 

ok. The other possibility is to modify the MII_88E1121_PHY_MSCR_REG regs
 only in RGMII_* case like for the 88e1111 case imho.
I'm sending a patch doing that right now.

Regards,
Arnaud




