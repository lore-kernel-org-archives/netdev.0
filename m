From: Jongsung Kim <neidhard.kim@lge.com>
Subject: Re: [PATCH 1/2] net: cadence: macb: add support for the WOL
Date: Tue, 15 Jul 2014 15:58:46 +0900
Message-ID: <53C4D126.5000005@lge.com>
References: <1405328538-29153-1-git-send-email-neidhard.kim@lge.com> <53C3ADB9.4010309@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D17271AC1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	'Varka Bhadram' <varkabhadram@gmail.com>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17271AC1@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14/2014 07:49 PM, David Laight wrote:
> From: Varka Bhadram
>> On 07/14/2014 02:32 PM, Jongsung Kim wrote:
>>> This patch enables the ethtool utility to control the WOL function
>>> of the PHY connected to the GEM/MACB. (if supported)
> ...
>>> +static int macb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
>>> +{
>>> +	struct macb *bp = netdev_priv(netdev);
>>> +	struct phy_device *phydev = bp->phy_dev;
>>> +	int err = -ENODEV;
>>> +
>>> +	if (phydev)
>>> +		err = phy_ethtool_set_wol(phydev, wol);
>>> +
>>> +	return err;
>>> +}
>>> +
>>
>> I think we can do in this way:
>>
>> if (phydev)
>> 	return phy_ethtool_set_wol(phydev, wol);
>> else
>> 	return -ENODEV;
>>
>>
>> we can save err. What do you say ...?
> 
> I would do:
> 	if (!phydev)
> 		return -ENODEV;
> 	return phy_ethtool_set_wol(phydev, wol);
> 
> Although it might even be worth moving the NULL test into the function.
> (sort of depends on style and the number of callers who need to do the test.)
> 

Totally agreed. I'd be better to submit a patch about it first.

> 	David
> 
> 
> 
> 
