From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH] Virtual ethernet device (v2.1)
Date: Wed, 11 Jul 2007 17:32:22 +0400
Message-ID: <4694DBE6.4080702@openvz.org>
References: <4694A363.2070406@openvz.org> <4694CBD9.90503@trash.net> <4694D0C5.6020700@openvz.org> <4694D2CC.10409@trash.net> <4694D473.3080707@openvz.org> <4694D741.80906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Ben Greear <greearb@candelatech.com>, devel@openvz.org,
	Kirill Korotaev <dev@openvz.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:29597 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756121AbXGKNco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 09:32:44 -0400
In-Reply-To: <4694D741.80906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelianov wrote:
>> Patrick McHardy wrote:
>>
>>> Mhh doing it later means dealing with compatibility issues, which
>>> is why I'm asking now. We currently support IFLA_NAME, IFLA_MTU,
>>
>> Oh, I see.
>>
>>
>>> IFLA_TXQLEN, IFLA_WEIGTH, IFLA_OPERSTATE and IFLA_LINKMODE, and
>>> with my patch additionally IFLA_ADDRESS and IFLA_BROADCAST.
>>> AFAICT they are all applicable for the partner link as well.
>>
>> Agree. Maybe it is better to make some generic routine to create the
>> device with the parameters specified in the netlink packet. Then the
>> generic code creates one end of a tunnel and calls ->new_link callback.
>> This callback extracts the PARTNER packet part and calls this generic
>> routine to create the second pair.
> 
> 
> Something like that. Moving the part between NLM_F_CREATE and the
> ops->newlink call of rtnl_newlink to a new function should work.
> 
> For now you could even parse the IFLA_PARTNER attribute and nested
> IFLA_NAME/IFLA_ADDRESS attributes yourself and ignore the rest,
> this will at least leave us the option of handling it generically
> later.

OK. I'll try to make the generic call. Could you please send me the
patches with IFLA_ADDRESS support for booth kernel and ip utility.

Thanks,
Pavel

