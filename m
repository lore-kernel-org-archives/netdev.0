From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH 1/2] net: cadence: macb: add support for the WOL
Date: Mon, 14 Jul 2014 16:23:09 +0530
Message-ID: <53C3B695.6000001@gmail.com>
References: <1405328538-29153-1-git-send-email-neidhard.kim@lge.com> <53C3ADB9.4010309@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D17271AC1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	Jongsung Kim <neidhard.kim@lge.com>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:52195 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbaGNKyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 06:54:22 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17271AC1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/2014 04:19 PM, David Laight wrote:
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
>> I think we can do in this way:
>>
>> if (phydev)
>> 	return phy_ethtool_set_wol(phydev, wol);
>> else
>> 	return -ENODEV;
>>
>>
>> we can save err. What do you say ...?
> I would do:
> 	if (!phydev)
> 		return -ENODEV;
> 	return phy_ethtool_set_wol(phydev, wol);

I will agree with this....  :-)

if (!phydev) {
	netdev_err("bla bla...");
	return -ENODEV;
}
return phy_ethtool_set_wol(phydev, wol);



-- 
Regards,
Varka Bhadram.
