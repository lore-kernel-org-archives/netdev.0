From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: bonding module can only be loaded once
Date: Tue, 09 Jun 2009 17:33:07 +0200
Message-ID: <4A2E80B3.6010600@trash.net>
References: <20090608151127.70146505@nehalam>	<200906091406.45463.arnd@arndb.de> <20090609080232.45f81833@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sf.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32899 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbZFIPdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:33:08 -0400
In-Reply-To: <20090609080232.45f81833@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -5203,7 +5203,7 @@ static int __init bonding_init(void)
>>  
>>  	res = bond_create_sysfs();
>>  	if (res)
>> -		goto err;
>> +		pr_info("Loading bonding module without sysfs interface\n");
>>  
>>  	register_netdevice_notifier(&bond_netdev_notifier);
>>  	register_inetaddr_notifier(&bond_inetaddr_notifier);
> 
> That only makes it limp along, and there still are warnings.
> The point is that who ever added the WARN() in proc and sysfs, effectively
> broke a bonding usage model.

It did already dump the stack before that change, didn't it?

In any case, this is not the first time this has been broken and the
fundamental reason is in my opinion that the bonding interface is
broken to begin with. The module aliasing thing is complete crap
and should have been phased out long ago. At this point its probably
not worth anymore to migrate people to the sysfs interface though,
the best thing would be to add an rtnl_link interface and phase out
both.
