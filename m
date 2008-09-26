From: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 14/18] netdevice airo: Convert directly reference of	netdev->priv
 to netdev->ml_priv
Date: Fri, 26 Sep 2008 16:37:05 +0800
Message-ID: <48DC9F31.4010807@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>	 <48C0A72B.9050407@cn.fujitsu.com>  <20080905125036.GA3027@tuxdriver.com> <1220634383.6430.14.camel@localhost.localdomain> <48C24F66.1090803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	NETDEV <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48C24F66.1090803-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wang Chen said the following on 2008-9-6 17:37:
>>>> We have some reasons to kill netdev->priv:
>>>> 1. netdev->priv is equal to netdev_priv().
>>>> 2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
>>>>    netdev_priv() is more flexible than netdev->priv.
>>>> But we cann't kill netdev->priv, because so many drivers reference to it
>>>> directly.
>>>>
>>>> OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
>>>> and I want to kill netdev->priv later, I decided to convert all the direct
>>>> reference of netdev->priv first.
>>>>
>>>> Different to readonly reference of netdev->priv, in this driver, netdev->priv
>>>> was changed. I use netdev->ml_priv to replace netdev->priv.
>>>>
>>>> Signed-off-by: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>>> Thank you for your patch.  However, I do not understand why you didn't
>>> simply replace netdev->priv with netdev_priv()?  Can you explain?
>> Yeah, that would have been my first choice too...
>>
> 
> 1. Why I don't use netdev_priv() to replace netdev->priv here?
> Because, here
>> @@ -2665,7 +2666,7 @@ static struct net_device *init_wifidev(struct airo_info *ai,
>>  	struct net_device *dev = alloc_netdev(0, "wifi%d", wifi_setup);
>>  	if (!dev)
>>  		return NULL;
>> -	dev->priv = ethdev->priv;
>> +	dev->ml_priv = ethdev->ml_priv;
>> @@ -2766,7 +2767,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
>>  		return NULL;
>>  	}
>>  
>> -	ai = dev->priv;
>> +	ai = dev->ml_priv = netdev_priv(dev);
> netdev->priv was changed here, but it shouldn't, the memory was allocated when alloc_netdev and
> netdev->priv should always pointed to that memory.
> 
> 2. Why I use netdev->ml_priv here to replace netdev->priv?
> In this driver, netdev->priv are shared by multi wifidevs, that means wifidevs need
> mid-layer private data, which are all same as their parent netdev.
> This usage is same as Dave's commit "syncppp: Fix crashes."
> 

John, do you have any comments about my answer?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
