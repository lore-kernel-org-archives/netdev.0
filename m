From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 1/5] bonding: Changed hashing function to just provide hash
Date: Mon, 31 Mar 2014 15:01:57 -0700
Message-ID: <CAF2d9jifmEt-01SmQ-MvYN09QsYD7efzCFuqVFma-7wDBAdu9w@mail.gmail.com>
References: <1396070925-17511-1-git-send-email-maheshb@google.com> <1396280686.29410.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:56526 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbaCaWCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 18:02:18 -0400
Received: by mail-vc0-f171.google.com with SMTP id lg15so8697642vcb.2
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 15:02:17 -0700 (PDT)
In-Reply-To: <1396280686.29410.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 8:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-03-28 at 22:28 -0700, Mahesh Bandewar wrote:
>> Modified the hash function to return just hash separating from the
>> modulo operation that can be performed by the caller. This is to
>> make way for the tlb mode to use the same hashing policies that
>> are used in the 802.3ad and Xor mode.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>
>
>> -int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count)
>> +int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
>>  {
>>       struct flow_keys flow;
>>       u32 hash;
>>
>>       if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER2 ||
>>           !bond_flow_dissect(bond, skb, &flow))
>> -             return bond_eth_hash(skb) % count;
>> +             return bond_eth_hash(skb);
>>
>>       if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER23 ||
>>           bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP23)
>> @@ -3039,7 +3037,7 @@ int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count)
>>       hash ^= (hash >> 16);
>>       hash ^= (hash >> 8);
>>
>> -     return hash % count;
>> +     return hash;
>>  }
>
>
> Sounds good, but I would change  bond_xmit_hash() to return an u32
> instead of 'int'
>
> There is an interesting mix of u32 and int in this bonding code :(
>
> slave_cnt is signed, so a  (signed_hash % signed_slave_cnt) could
> potentially be negative ?
>
>
Yes, it does make sense to change it to u32. Thanks.
