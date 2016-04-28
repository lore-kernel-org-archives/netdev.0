From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net] ipv6/ila: fix nlsize calculation for lwtunnel
Date: Thu, 28 Apr 2016 12:16:39 -0400 (EDT)
Message-ID: <20160428.121639.1149681033434022894.davem@davemloft.net>
References: <1461340682-31568-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160427.152053.2243888701043810040.davem@davemloft.net>
	<CALx6S36jkPqx5U+B9akRYZ+xiRhozk_AdOmKBEr4N9mhwTKQMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366AbcD1QQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 12:16:43 -0400
In-Reply-To: <CALx6S36jkPqx5U+B9akRYZ+xiRhozk_AdOmKBEr4N9mhwTKQMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 28 Apr 2016 09:07:25 -0700

> On Wed, Apr 27, 2016 at 12:20 PM, David Miller <davem@davemloft.net> wrote:
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Fri, 22 Apr 2016 17:58:02 +0200
>>
>>> The handler 'ila_fill_encap_info' adds one attribute: ILA_ATTR_LOCATOR.
>>>
>>> Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
>>> CC: Tom Herbert <tom@herbertland.com>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> ---
>>>
>>> Tom, when I read the comment, I feel I'm misssing something, but what?
>>
>> Tom, seriously, please look at this.
>>
> Yes, it is an issue. Need to do add size for ILA_ATTR_LOCATOR and
> ILA_ATTR_CSUM_MODE. Also not we made ILA_ATTR_CSUM_MODE u64 in fill
> encap info. I will send a path shortly.
> 
>> And with recent changes in net-next the csum attribute size needs to
>> be specified as well, plus the locator needs to use the 64-bit
>> alignment sizing helper.
> 
> Something other than nla_put_u64_64bit?

That's what it should use, yes.
