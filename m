From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v3 net-next] ipmr: change the prototype of ip_mr_forward().
Date: Sat, 20 Jul 2013 22:25:21 +0200
Message-ID: <51EAF231.40308@6wind.com>
References: <1374322168-5115-1-git-send-email-ramirose@gmail.com> <51EAF15D.7080307@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:57090 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831Ab3GTUZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 16:25:27 -0400
Received: by mail-wi0-f181.google.com with SMTP id hq4so671064wib.8
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 13:25:25 -0700 (PDT)
In-Reply-To: <51EAF15D.7080307@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the disclaimer in the previous email. I forget to remove it.
Please, ignore it.


Thank you,
Nicolas

Le 20/07/2013 22:21, Nicolas Dichtel a =C3=A9crit :
> Le 20/07/2013 14:09, Rami Rosen a =C3=A9crit :
>> This patch changes the prototpye of the ip_mr_forward() method to re=
turn void
>> instead of int.
>>
>> The ip_mr_forward() method always returns 0; moreover, the return va=
lue of this
>> method is not checked anywhere.
>>
>> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
>> ---
>>   net/ipv4/ipmr.c | 15 +++++++--------
>>   1 file changed, 7 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
>> index 132a096..bacc0bc 100644
>> --- a/net/ipv4/ipmr.c
>> +++ b/net/ipv4/ipmr.c
>> @@ -127,9 +127,9 @@ static struct kmem_cache *mrt_cachep __read_most=
ly;
>>   static struct mr_table *ipmr_new_table(struct net *net, u32 id);
>>   static void ipmr_free_table(struct mr_table *mrt);
>>
>> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
>> -             struct sk_buff *skb, struct mfc_cache *cache,
>> -             int local);
>> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
>> +              struct sk_buff *skb, struct mfc_cache *cache,
>> +              int local);
>>   static int ipmr_cache_report(struct mr_table *mrt,
>>                    struct sk_buff *pkt, vifi_t vifi, int assert);
>>   static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff=
 *skb,
>> @@ -1795,9 +1795,9 @@ static int ipmr_find_vif(struct mr_table *mrt,=
 struct
>> net_device *dev)
>>
>>   /* "local" means that we should preserve one skb (for local delive=
ry) */
>>
>> -static int ip_mr_forward(struct net *net, struct mr_table *mrt,
>> -             struct sk_buff *skb, struct mfc_cache *cache,
>> -             int local)
>> +static void ip_mr_forward(struct net *net, struct mr_table *mrt,
>> +              struct sk_buff *skb, struct mfc_cache *cache,
>> +              int local)
>>   {
>>       int psend =3D -1;
>>       int vif, ct;
>> @@ -1903,14 +1903,13 @@ last_forward:
>>                   ipmr_queue_xmit(net, mrt, skb2, cache, psend);
>>           } else {
>>               ipmr_queue_xmit(net, mrt, skb, cache, psend);
>> -            return 0;
>> +            return;
>>           }
>>       }
>>
>>   dont_forward:
>>       if (!local)
>>           kfree_skb(skb);
>> -    return 0;
>>   }
>>
>>   static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct=
 sk_buff
>> *skb)
>>
>
