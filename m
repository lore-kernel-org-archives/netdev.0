From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH v2 net-next 1/2] net: use dev->name in netdev_pr* when
 it's available
Date: Thu, 17 Jul 2014 18:25:53 +0200
Message-ID: <20140717162553.GD28357@mikrodark.usersys.redhat.com>
References: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
 <1405606186-13703-2-git-send-email-vfalico@gmail.com>
 <1405613924.12363.24.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:37835 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933607AbaGQQ2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 12:28:53 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so2267070wgh.21
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 09:28:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405613924.12363.24.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 09:18:44AM -0700, Joe Perches wrote:
>On Thu, 2014-07-17 at 16:09 +0200, Veaceslav Falico wrote:
>> netdev_name() returns dev->name only when the net_device is in
>> NETREG_REGISTERED state.
>>
>> However, dev->name is always populated on creation, so we can easily use
>> it.
>>
>> There are two cases when there's no real name - when it's an empty string
>> or when the name is in form of "eth%d", then netdev_name() returns "unnamed
>> net_device".
>>
>> CC: "David S. Miller" <davem@davemloft.net>
>> CC: Tom Gundersen <teg@jklm.no>
>> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>> ---
>>
>> Notes:
>>     v1->v2:
>>     Also account for an empty string, as Tom Gundersen suggested.
>>
>>  include/linux/netdevice.h | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 15ed750..70256aa 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -3383,8 +3383,8 @@ extern struct pernet_operations __net_initdata loopback_net_ops;
>>
>>  static inline const char *netdev_name(const struct net_device *dev)
>>  {
>> -	if (dev->reg_state != NETREG_REGISTERED)
>> -		return "(unregistered net_device)";
>> +	if (!dev->name[0] || strchr(dev->name, '%'))
>> +		return "(unnamed net_device)";
>>  	return dev->name;
>>  }
>>
>
>Maybe this should not be inline and become something like:

It will miss the states then, when it's not NETREG_REGISTERED.

>
>const char *netdev_name(const struct net_device *dev)
>{
>	if (dev->reg_state == NETREG_REGISTERED)
>		return dev->name;
>
>	if (!dev->name[0])
>		return "(unnamed net_device)";
>
>	if (!strchr(dev->name, '%'))
>		return "(unregistered net_device)";
>
>	return dev->name;
>}
>EXPORT_SYMBOL(netdev_name);
>
>
