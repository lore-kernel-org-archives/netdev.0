From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] bonding: create netlink event when bonding
 option is changed
Date: Wed, 20 Aug 2014 14:49:22 +0200
Message-ID: <20140820124922.GE1916@nanopsycho.orion>
References: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
 <20140820121828.GA31336@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
	vfalico@gmail.com, andy@greyhouse.net, nikolay@redhat.com,
	dingtianhong@huawei.com, sfeldma@cumulusnetworks.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:56181 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341AbaHTMt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 08:49:26 -0400
Received: by mail-wg0-f43.google.com with SMTP id l18so7795886wgh.14
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2014 05:49:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140820121828.GA31336@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 20, 2014 at 02:18:28PM CEST, nhorman@tuxdriver.com wrote:
>On Tue, Aug 19, 2014 at 04:02:12PM +0200, Jiri Pirko wrote:
>> Userspace needs to be notified if one changes some option.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  drivers/net/bonding/bond_options.c | 2 ++
>>  include/linux/netdevice.h          | 1 +
>>  2 files changed, 3 insertions(+)
>> 
>> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>> index dc73463..d8dc17f 100644
>> --- a/drivers/net/bonding/bond_options.c
>> +++ b/drivers/net/bonding/bond_options.c
>> @@ -625,6 +625,8 @@ int __bond_opt_set(struct bonding *bond,
>>  out:
>>  	if (ret)
>>  		bond_opt_error_interpret(bond, opt, ret, val);
>> +	else
>> +		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
>>  
>>  	return ret;
>>  }
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 967ddcc..44bc4bd 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -2017,6 +2017,7 @@ struct pcpu_sw_netstats {
>>  #define NETDEV_CHANGEUPPER	0x0015
>>  #define NETDEV_RESEND_IGMP	0x0016
>>  #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
>> +#define NETDEV_CHANGEINFODATA	0x0018
>>  
>Do you need to create a new netdev event here?  Seems like it might be more
>concise to reuse NETDEV_CHANGE and expand the netdev_notifier_change_info
>struct.

No, I would not like to do that. There are many notifiers processing
NETDEV_CHANGE now. Plus there is no limitation in adding event number.
Plus since this it not part of any api, it can be easily changed. I
prefer to add another event number.

>
>Neil
>
>>  int register_netdevice_notifier(struct notifier_block *nb);
>>  int unregister_netdevice_notifier(struct notifier_block *nb);
>> -- 
>> 1.9.3
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
