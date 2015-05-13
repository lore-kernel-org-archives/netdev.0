From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/5] net: Get skb hash over flow_keys
 structure
Date: Wed, 13 May 2015 16:02:20 -0400 (EDT)
Message-ID: <20150513.160220.46676209141435421.davem@davemloft.net>
References: <1431444182-3935169-2-git-send-email-tom@herbertland.com>
	<20150513.153007.1923480989811217786.davem@davemloft.net>
	<CALx6S36JxtWZP+b=UGhuyBpgNvi4B9YggZ_+s1zSRrk74cGNdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965321AbbEMUCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 16:02:22 -0400
In-Reply-To: <CALx6S36JxtWZP+b=UGhuyBpgNvi4B9YggZ_+s1zSRrk74cGNdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 13 May 2015 15:37:50 -0400

> On Wed, May 13, 2015 at 3:30 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Tue, 12 May 2015 08:22:58 -0700
>>
>>> @@ -15,6 +15,13 @@
>>>   * All the members, except thoff, are in network byte order.
>>>   */
>>>  struct flow_keys {
>>> +     u16     thoff;
>>> +     u16     padding1;
>>> +#define FLOW_KEYS_HASH_START_FIELD   n_proto
>>> +     __be16  n_proto;
>>> +     u8      ip_proto;
>>> +     u8      padding;
>>> +
>>
>> This padding works if everyone consistently zero initializes the whole
>> key structure, but for whatever reason (performance, unintentional
>> oversight, etc.) not all paths do.
>>
>> So, for example, inet_set_txhash() is going to have random crap in
>> keys.padding, so the hashes computed are not stable for a given flow
>> key tuple.
>>
>> That's just the first code path I found with this issue, there are
>> probably several others.
> 
> memset zero is in the second patch for inet_set_txhash and
> ip6_set_txhash. I can respin so those are in the first patch.

Yes, for bisectability you should probably do that.
