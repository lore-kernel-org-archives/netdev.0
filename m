From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH: 2.6.12-rc1] mii: Add test for GigE support
Date: Tue, 22 Mar 2005 20:47:39 -0500
Message-ID: <4240CABB.5090701@pobox.com>
References: <20050322231746.GA27770@xyzzy> <4240A9F3.5040704@pobox.com> <212e5bf54766a68d2ab8716574225203@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>,
        James Chapman <jchapman@katalix.com>, Netdev <netdev@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <212e5bf54766a68d2ab8716574225203@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
> 
> On Mar 22, 2005, at 17:27, Jeff Garzik wrote:
> 
>>>  +int mii_check_gmii_support(struct mii_if_info *mii)
>>> +{
>>> +    int reg;
>>> +
>>> +    reg = mii->mdio_read(mii->dev, mii->phy_id, MII_BMSR);
>>> +    if (reg & BMSR_HAS_EXTSTAT1000) {
>>> +        reg = mii->mdio_read(mii->dev, mii->phy_id, MII_EXTSTAT1000);
>>> +        if (reg & (ESR_1000_BASE_X_FD | ESR_1000_BASE_T_FD |
>>> +               ESR_1000_BASE_X_HD | ESR_1000_BASE_T_HD))
>>> +            return 1;
>>> +    }
>>> +
>>> +    return 0;
>>
>>
>> 2) Reading a non-existent register will return all 1's in most cases, 
>> so I am not sure if this is the best test.
> 
> 
> He reads a standard register (BMSR) to determine whether or not 
> EXTSTAT1000 exists.  This is part of the 802.3 standard, so it should work.

Whoops, I read the patch incorrectly, and thought he read an extended 
register.

Objection removed.  Still need an EXPORT_SYMBOL() though.

	Jeff
