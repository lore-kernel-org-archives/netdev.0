From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH: 2.6.12-rc1] mii: Add test for GigE support
Date: Tue, 22 Mar 2005 19:21:56 -0600
Message-ID: <212e5bf54766a68d2ab8716574225203@freescale.com>
References: <20050322231746.GA27770@xyzzy> <4240A9F3.5040704@pobox.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>,
        James Chapman <jchapman@katalix.com>, Netdev <netdev@oss.sgi.com>
In-Reply-To: <4240A9F3.5040704@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mar 22, 2005, at 17:27, Jeff Garzik wrote:
>>  +int mii_check_gmii_support(struct mii_if_info *mii)
>> +{
>> +	int reg;
>> +
>> +	reg = mii->mdio_read(mii->dev, mii->phy_id, MII_BMSR);
>> +	if (reg & BMSR_HAS_EXTSTAT1000) {
>> +		reg = mii->mdio_read(mii->dev, mii->phy_id, MII_EXTSTAT1000);
>> +		if (reg & (ESR_1000_BASE_X_FD | ESR_1000_BASE_T_FD |
>> +			   ESR_1000_BASE_X_HD | ESR_1000_BASE_T_HD))
>> +			return 1;
>> +	}
>> +
>> +	return 0;
>
> 2) Reading a non-existent register will return all 1's in most cases, 
> so I am not sure if this is the best test.

He reads a standard register (BMSR) to determine whether or not 
EXTSTAT1000 exists.  This is part of the 802.3 standard, so it should 
work.

Andy


Andy Fleming
