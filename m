From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Tue, 27 Jan 2015 00:12:26 -0800 (PST)
Message-ID: <20150127.001226.711259930266409202.davem@davemloft.net>
References: <1422327262-6344-1-git-send-email-fan.du@intel.com>
	<20150126.233938.513240875461315013.davem@davemloft.net>
	<54C741E4.2000009@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: fan.du@intel.com, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: fengyuleidian0615@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101AbbA0IM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:12:28 -0500
In-Reply-To: <54C741E4.2000009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fengyuleidian0615@gmail.com>
Date: Tue, 27 Jan 2015 15:44:36 +0800

> 于 2015年01月27日 15:39, David Miller 写道:
>> From: Fan Du <fan.du@intel.com>
>> Date: Tue, 27 Jan 2015 10:54:22 +0800
>>
>>> @@ -2419,6 +2419,11 @@ static int xfrm_user_rcv_msg(struct sk_buff
>>> *skb, struct nlmsghdr *nlh)
>>>   	const struct xfrm_link *link;
>>>   	int type, err;
>>>
>>> +#ifdef CONFIG_COMPAT
>>> +	if (is_compat_task())
>>> +		return -EPERM;
>>> +#endif
>>> +
>>
>> This seems more like an unsupported operation rather then a permission
>> problem.
>>
> how about *ENOTSUPP* ?

Unquestionably, that is an improvement over EPERM.
