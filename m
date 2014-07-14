From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next] enic: Add ethtool support to show classifier
 filters added by the driver
Date: Mon, 14 Jul 2014 12:28:58 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1407141150300.4699@ws.cisco>
References: <1405070051-10445-1-git-send-email-_govind@gmx.com> <20140711.145917.653569199285104303.davem@davemloft.net> <alpine.LNX.2.03.1407121406100.1782@ws.cisco> <20140713.003145.1522390926593819876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:61888 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbaGNG7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2014 02:59:30 -0400
In-Reply-To: <20140713.003145.1522390926593819876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Jul 2014, David Miller wrote:

> From: Govindarajulu Varadarajan <_govind@gmx.com>
> Date: Sat, 12 Jul 2014 14:09:15 +0530 (IST)
>
>> On Fri, 11 Jul 2014, David Miller wrote:
>>
>>> From: Govindarajulu Varadarajan <_govind@gmx.com>
>>> Date: Fri, 11 Jul 2014 14:44:11 +0530
>>>
>>>> Right now Accelerated RFS is the only feature which adds classifier
>>>> filters.
>>>> So enable get_rxnfc only when CONFIG_RFS_ACCEL = y
>>> ...
>>>> @@ -293,6 +389,9 @@ static const struct ethtool_ops enic_ethtool_ops =
>>>> {
>>>>  	.get_ethtool_stats = enic_get_ethtool_stats,
>>>>  	.get_coalesce = enic_get_coalesce,
>>>>  	.set_coalesce = enic_set_coalesce,
>>>> +#ifdef CONFIG_RFS_ACCEL
>>>> +	.get_rxnfc = enic_get_rxnfc,
>>>> +#endif
>>>
>>> No other driver protects this method in this way, please don't do
>>> this.
>>>
>>
>> I will move the ifdef's to .h files and resubmit.
>
> I meant, at all.
>

You do not like the idea of #ifdef around .get_rxnfc (including moving it to
.h file) or the idea of displaying filters added by RFS?

I am actually considering moving driver filter structures out of
#ifdef CONFIG_RFS_ACCEL, and make it available always. This will allow us to
define .get_rxnfc without any #ifdefs.

This change is anyway needed when I implement .set_rxnfc to added user entered
filters.

This it fine with you?

Thanks
