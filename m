From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 net-next 1/5] net: Get skb hash over flow_keys structure
Date: Wed, 13 May 2015 15:37:50 -0400
Message-ID: <CALx6S36JxtWZP+b=UGhuyBpgNvi4B9YggZ_+s1zSRrk74cGNdw@mail.gmail.com>
References: <1431444182-3935169-1-git-send-email-tom@herbertland.com>
	<1431444182-3935169-2-git-send-email-tom@herbertland.com>
	<20150513.153007.1923480989811217786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35075 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934424AbbEMThv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:37:51 -0400
Received: by igbyr2 with SMTP id yr2so148586072igb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 12:37:50 -0700 (PDT)
In-Reply-To: <20150513.153007.1923480989811217786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 3:30 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Tue, 12 May 2015 08:22:58 -0700
>
>> @@ -15,6 +15,13 @@
>>   * All the members, except thoff, are in network byte order.
>>   */
>>  struct flow_keys {
>> +     u16     thoff;
>> +     u16     padding1;
>> +#define FLOW_KEYS_HASH_START_FIELD   n_proto
>> +     __be16  n_proto;
>> +     u8      ip_proto;
>> +     u8      padding;
>> +
>
> This padding works if everyone consistently zero initializes the whole
> key structure, but for whatever reason (performance, unintentional
> oversight, etc.) not all paths do.
>
> So, for example, inet_set_txhash() is going to have random crap in
> keys.padding, so the hashes computed are not stable for a given flow
> key tuple.
>
> That's just the first code path I found with this issue, there are
> probably several others.

memset zero is in the second patch for inet_set_txhash and
ip6_set_txhash. I can respin so those are in the first patch.

Tom
