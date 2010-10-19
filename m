From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: Re: [patch 1/1] phy/marvell: fix 88e1121 support
Date: Tue, 19 Oct 2010 13:49:20 +0200
Message-ID: <87y69ue727.fsf@lechat.rtp-net.org>
References: <20101018214401.053486146@rtp-net.org>
	<20101018214414.375368957@rtp-net.org> <4CBCC3FC.2030506@ti.com>
	<20101018222947.418028323@rtp-net.org>
	<20101018223056.716357140@rtp-net.org> <4CBD785E.8040704@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: cyril@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lechat.rtp-net.org ([88.191.19.38]:42682 "EHLO
	lechat.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758154Ab0JSLrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 07:47:05 -0400
In-Reply-To: <4CBD785E.8040704@ti.com> (Cyril Chemparathy's message of "Tue\, 19 Oct 2010 06\:52\:14 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyril Chemparathy <cyril@ti.com> writes:

> Hi Arnaud,

Hi,

>
> On 10/18/2010 06:29 PM, Arnaud Patard wrote:
>> Commit c477d0447db08068a497e7beb892b2b2a7bff64b added support for RGMII
>> rx/tx delays except that it ends up clearing rx/tx delays bit for modes
>> differents that RGMII*ID. Due to this, ethernet is not working anymore
>> on my guruplug server +. This patch is fixing that.
>> 
>> Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>
>> Index: linux-2.6/drivers/net/phy/marvell.c
>> ===================================================================
>> --- linux-2.6.orig/drivers/net/phy/marvell.c	2010-10-18 22:46:09.000000000 +0200
>> +++ linux-2.6/drivers/net/phy/marvell.c	2010-10-19 00:20:22.000000000 +0200
>> @@ -196,20 +196,27 @@
>>  			MII_88E1121_PHY_MSCR_PAGE);
>>  	if (err < 0)
>>  		return err;
>> -	mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
>> -		MII_88E1121_PHY_MSCR_DELAY_MASK;
>>  
>> -	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
>> -		mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
>> -			 MII_88E1121_PHY_MSCR_TX_DELAY);
>> -	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
>> -		mscr |= MII_88E1121_PHY_MSCR_RX_DELAY;
>> -	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
>> -		mscr |= MII_88E1121_PHY_MSCR_TX_DELAY;
>> +	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
>> +	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
>> +	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
>> +	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
>>  
>> -	err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
>> -	if (err < 0)
>> -		return err;
>> +		mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
>> +			MII_88E1121_PHY_MSCR_DELAY_MASK;
>> +
>> +		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
>> +			mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
>> +				 MII_88E1121_PHY_MSCR_TX_DELAY);
>> +		else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
>> +			mscr |= MII_88E1121_PHY_MSCR_RX_DELAY;
>> +		else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
>> +			mscr |= MII_88E1121_PHY_MSCR_TX_DELAY;
>> +
>> +		err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
>> +		if (err < 0)
>> +			return err;
>> +	}
>>  
>>  	phy_write(phydev, MII_88E1121_PHY_PAGE, oldpage);
>
> That looks more correct.  Just out of curiosity, what is the interface
> mode on your platform?

The interface is in GMII mode iirc. The device is the ethernet embedded
in the Kirkwood SoC with a 88e1121 phy connected. It's handled by the
mv643xx_eth driver and the marvell phy driver.

Arnaud
