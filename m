From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 30 May 2007 20:57:33 +0200
Message-ID: <465DC91D.1030104@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de>	<20070530131204.10843.5@janus.isnogud.escape.de> <20070530102810.1689119b@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:26201 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756575AbXE3S5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 14:57:50 -0400
In-Reply-To: <20070530102810.1689119b@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> In addition to Patrick's comments.
>
>   
>> +
>> +static void vcan_init(struct net_device *dev)
>> +{
>> +	DBG("dev %s\n", dev->name);
>> +
>> +	ether_setup(dev);
>>     
>
> Do really want to do this?
>   - you set different flags/type after this.
>   - do you really want change_mtu to call eth_change_mtu
> Better off to just copy what you want out of ether_setup if
> your device is not really an ether device.
>   

Yep! That's reasonable. Thanks.


>> +
>> +	dev->type              = ARPHRD_CAN;
>> +	dev->mtu               = sizeof(struct can_frame);
>> +	dev->flags             = IFF_NOARP;
>> +
>> +	/* set flags according to driver capabilities */
>> +	if (loopback)
>> +		dev->flags |= IFF_LOOPBACK;
>> +
>> +	dev->open              = vcan_open;
>> +	dev->stop              = vcan_stop;
>> +	dev->set_config        = NULL;
>>     
> unneeded
>
>   
>> +	dev->hard_start_xmit   = vcan_tx;
>> +	dev->do_ioctl          = vcan_ioctl;
>> +	dev->get_stats         = vcan_get_stats;
>> +	dev->hard_header       = vcan_header;
>> +	dev->rebuild_header    = vcan_rebuild_header;
>> +	dev->hard_header_cache = NULL;
>>     
> unneeded
>
>   

Does 'unneeded' belong to always the last line of the quoted code snippet?

Regards,
Oliver


