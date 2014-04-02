From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v3 1/5] bonding: Changed hashing function to just provide hash
Date: Wed, 2 Apr 2014 11:00:57 -0700
Message-ID: <CAF2d9jh=QdgpWByGcuLgkavvh0khH6o4xYxksAjzXdeAE1rx0g@mail.gmail.com>
References: <1396422007-31930-1-git-send-email-maheshb@google.com> <1396435815.3989.23.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mail-vc0-f174.google.com ([209.85.220.174]:61792 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332AbaDBSBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 14:01:18 -0400
Received: by mail-vc0-f174.google.com with SMTP id ld13so837110vcb.33
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 11:01:18 -0700 (PDT)
In-Reply-To: <1396435815.3989.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 2, 2014 at 3:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-04-02 at 00:00 -0700, Mahesh Bandewar wrote:
>> Modified the hash function to return just hash separating from the
>> modulo operation that can be performed by the caller. This is to
>> make way for the tlb mode to use the same hashing policies that
>> are used in the 802.3ad and Xor mode.
>>
>> Change-Id: I276609e87e0ca213c4d1b17b79c5e0b0f3d0dd6f
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>> v2:
>>   Change the return type of bond_xmit_hash() from int to u32
>> v3:
>>   Rebase.
>>
>>  drivers/net/bonding/bond_3ad.c  |  3 ++-
>>  drivers/net/bonding/bond_main.c | 10 ++++------
>>  drivers/net/bonding/bonding.h   |  2 +-
>>  3 files changed, 7 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index b667a51ed215..ccf2639e916f 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -30,6 +30,7 @@
>>  #include <linux/etherdevice.h>
>>  #include <linux/if_bonding.h>
>>  #include <linux/pkt_sched.h>
>> +#include <net/sock.h>
>
> Not sure why you added this include ?
>
Hmm it may be result of a cherry-pick or left-over from an experiment.
But will eliminate it as it's clearly not needed in this patch.

>>  #include <net/net_namespace.h>
>>  #include "bonding.h"
>>  #include "bond_3ad.h"
>> @@ -2440,7 +2441,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>>               goto err_free;
>>       }
>>
>> -     slave_agg_no = bond_xmit_hash(bond, skb, slaves_in_agg);
>> +     slave_agg_no = bond_xmit_hash(bond, skb) % slaves_in_agg;
>>       first_ok_slave = NULL;
>>
>>       bond_for_each_slave_rcu(bond, slave, iter) {
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>
> Otherwise, seems fine to me
>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
>
