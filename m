From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] Implement NETDEV_FEAT_CHANGE
Date: Tue, 24 May 2005 00:32:19 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505232350060.17855@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505201527250.26127@webhosting.rdsbv.ro>
 <20050523093329.40617690@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050523093329.40617690@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 May 2005, Stephen Hemminger wrote:

>
>> --- notify1/net/core/ethtool.c	2005-03-02 09:38:37.000000000 +0200
>> +++ linux/net/core/ethtool.c	2005-05-23 11:30:47.000000000 +0300
> ...
>> @@ -712,7 +715,6 @@ int dev_ethtool(struct ifreq *ifr)
>>  		break;
>>  	case ETHTOOL_GDRVINFO:
>>  		rc = ethtool_get_drvinfo(dev, useraddr);
>> -
>>  		break;
>
> White space creep

Do you want to not touch that space?

>>  	case ETHTOOL_GREGS:
>>  		rc = ethtool_get_regs(dev, useraddr);
>> @@ -801,6 +803,10 @@ int dev_ethtool(struct ifreq *ifr)
>>
>>  	if(dev->ethtool_ops->complete)
>>  		dev->ethtool_ops->complete(dev);
>> +
>> +	if (old_features != dev->features)
>> +		netdev_features_change(dev);
>> +
>>  	return rc;
>>
>>   ioctl:
>
> Did you check for any  drivers that don't use ethtool_ops?

I checked now and I didn't find any possibility to change features.
So I think we are ok.

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
