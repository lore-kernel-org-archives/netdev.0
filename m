From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Mon, 29 Jun 2009 10:47:44 +0200
Message-ID: <4A487FB0.7010903@itcare.pl>
References: <19012.37515.146191.198843@robur.slu.se> <20090627192057.GA5041@ami.dom.local> <19015.20051.432572.460207@robur.slu.se> <20090628143511.GA20541@ami.dom.local> <4A478D02.10805@itcare.pl> <4A4790C3.508@itcare.pl> <20090628213602.GA4584@ami.dom.local> <4A48766B.8020206@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:38200 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbZF2Irp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 04:47:45 -0400
In-Reply-To: <4A48766B.8020206@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

But
With all this patches i have the same problem with CPU load
Every time when route cache entries are purged cpu load is increasing=20
from 1% to 40 / 80% it depends

I see that on 64bit machine when route cache entries are going down i=20
have almost 80% load on each cpu where ethernet card is binded by=20
smp_affinity
But on 32bit machine cpu load reported by mpstat is half that on 64bit=20
machine
here is example from 32bit machine ( mpstat + rtstat -k entries )

Linux 2.6.29.5 (TM_02_C1)       06/29/09        _i686_  (2 CPU)

12:36:54     CPU    %usr   %nice    %sys %iowait    %irq   %soft =20
%steal  %guest   %idle        RT CACHE ENTRIES (from rtstat)
12:36:57     all    0.00    0.00    0.00    0.00    1.51   15.08   =20
0.00    0.00   83.42        83346
12:36:58     all    0.00    0.00    0.00    0.00    1.01    7.58   =20
0.00    0.00   91.41        85988
12:36:59     all    0.00    0.00    0.00    0.00    0.50    1.01   =20
0.00    0.00   98.49        89979
12:37:00     all    0.00    0.00    0.50    0.00    0.00    1.51   =20
0.00    0.00   97.99        93652
12:37:01     all    0.00    0.00    0.00    0.00    0.00    2.01   =20
0.00    0.00   97.99        96533
12:37:02     all    0.00    0.00    0.00    0.00    0.51    1.01   =20
0.00    0.00   98.48        99451
12:37:03     all    0.00    0.00    0.00    0.00    0.00    2.49   =20
0.00    0.00   97.51        102018
12:37:04     all    0.00    0.00    0.00    0.00    0.00    1.52   =20
0.00    0.00   98.48        104153
12:37:05     all    0.00    0.00    0.00    0.00    0.00    1.01   =20
0.00    0.00   98.99        105979
12:37:06     all    0.00    0.00    0.00    0.00    0.00    1.01   =20
0.00    0.00   98.99        107684
12:37:07     all    0.00    0.00    0.00    0.00    0.00    1.53   =20
0.00    0.00   98.47        109070
12:37:08     all    0.00    0.00    0.00    0.00    0.00    1.51   =20
0.00    0.00   98.49        110462
12:37:09     all    0.00    0.00    0.00    0.00    0.00    1.52   =20
0.00    0.00   98.48        112301
12:37:10     all    0.00    0.00    0.00    0.00    2.00   20.00   =20
0.00    0.00   78.00        111535
12:37:11     all    0.00    0.00    0.00    0.00    2.49   34.33   =20
0.00    0.00   63.18        108659
12:37:12     all    0.00    0.00    0.00    0.00    3.03   28.28   =20
0.00    0.00   68.69        105534
12:37:13     all    0.00    0.00    0.00    0.00    3.98   30.85   =20
0.00    0.00   65.17        103341
12:37:14     all    0.00    0.00    0.00    0.00    4.50   30.50   =20
0.00    0.00   65.00        101307
12:37:15     all    5.56    0.00    0.00    0.00    1.52   28.79   =20
0.00    0.00   64.14        97435
12:37:16     all   11.39    0.00    0.50    0.00    4.95   30.69   =20
0.00    0.00   52.48        93908
12:37:17     all    1.51    0.00    0.00    0.00    1.01   27.64   =20
0.00    0.00   69.85        90229
12:37:18     all    0.00    0.00    0.00    0.00    2.99   27.36   =20
0.00    0.00   69.65        87030
12:37:19     all    0.00    0.00    0.00    0.00    3.02   29.65   =20
0.00    0.00   67.34        84324
12:37:20     all    0.00    0.00    0.00    0.00    2.99   30.35   =20
0.00    0.00   66.67        82167
12:37:21     all    0.00    0.00    0.00    0.00    1.98   31.68   =20
0.00    0.00   66.34        80121
12:37:22     all    0.00    0.00    0.00    0.00    1.51   30.65   =20
0.00    0.00   67.84        77850
12:37:23     all    0.00    0.00    0.00    0.00    2.50   28.50   =20
0.00    0.00   69.00        76005
12:37:24     all    0.00    0.00    0.00    0.00    1.98   23.27   =20
0.00    0.00   74.75        74538
12:37:25     all    0.00    0.00    0.49    0.00    2.93   22.44   =20
0.00    0.00   74.15        76923
12:37:26     all    0.00    0.00    0.00    0.00    1.51   15.58   =20
0.00    0.00   82.91        79396
12:37:27     all    0.00    0.00    0.00    0.00    0.50    7.96   =20
0.00    0.00   91.54        81835
12:37:28     all    0.00    0.00    0.00    0.00    0.50    3.52   =20
0.00    0.00   95.98        84169
12:37:29     all    0.00    0.00    0.00    0.00    0.00    2.02   =20
0.00    0.00   97.98        87740
12:37:30     all    0.00    0.00    0.00    0.00    0.51    1.52   =20
0.00    0.00   97.98        91152
12:37:31     all    0.00    0.00    0.00    0.00    0.00    1.99   =20
0.00    0.00   98.01        94102
12:37:32     all    0.00    0.00    0.00    0.00    0.00    1.52   =20
0.00    0.00   98.48        97032
12:37:33     all    0.00    0.00    0.00    0.00    0.00    0.50   =20
0.00    0.00   99.50        99685
12:37:34     all    0.00    0.00    0.00    0.00    0.00    1.00   =20
0.00    0.00   99.00        101970
12:37:35     all    0.00    0.00    0.00    0.00    0.50    1.00   =20
0.00    0.00   98.50        103814
12:37:36     all    0.00    0.00    0.00    0.00    0.00    1.52   =20
0.00    0.00   98.48        104793
12:37:37     all    0.00    0.00    0.00    0.00    0.00    1.01   =20
0.00    0.00   98.99        106214
12:37:38     all    0.00    0.00    0.00    0.00    0.50    1.01   =20
0.00    0.00   98.49        107300
12:37:39     all    0.00    0.00    0.00    0.00    0.00   13.00   =20
0.00    0.00   87.00        111951
12:37:40     all    0.00    0.00    0.00    0.00    2.50   29.50   =20
0.00    0.00   68.00        111215
12:37:41     all    0.00    0.00    0.00    0.00    2.01   30.65   =20
0.00    0.00   67.34        108023
12:37:42     all    0.00    0.00    0.00    0.00    2.99   29.85   =20
0.00    0.00   67.16        104751
12:37:43     all    0.00    0.00    0.00    0.00    2.00   31.00   =20
0.00    0.00   67.00        100827
12:37:44     all    0.00    0.00    0.00    0.00    3.00   27.00   =20
0.00    0.00   70.00        97184
12:37:45     all    0.00    0.00    0.00    0.00    2.50   29.00   =20
0.00    0.00   68.50        93904
12:37:46     all    0.00    0.00    0.00    0.00    3.02   30.15   =20
0.00    0.00   66.83        90979
12:37:47     all    0.00    0.00    0.00    0.00    2.49   27.86   =20
0.00    0.00   69.65        88315
12:37:48     all    0.00    0.00    0.00    0.00    2.48   31.19   =20
0.00    0.00   66.34        87777
12:37:49     all    0.00    0.00    0.00    0.00    2.94   32.35   =20
0.00    0.00   64.71        89218
12:37:50     all    0.00    0.00    0.00    0.00    3.00   32.50   =20
0.00    0.00   64.50        85896
12:37:51     all    0.00    0.00    0.00    0.00    2.50   30.00   =20
0.00    0.00   67.50        82712
12:37:52     all    0.50    0.00    0.00    0.00    2.49   30.85   =20
0.00    0.00   66.17        79137
12:37:53     all    0.00    0.00    0.50    0.00    2.00   28.50   =20
0.00    0.00   69.00        75644
12:37:54     all    0.00    0.00    0.00    0.00    2.51   30.65   =20
0.00    0.00   66.83        72843
12:37:55     all    0.00    0.00    0.50    0.00    3.48   28.36   =20
0.00    0.00   67.66        73460


Pawe=B3 Staszewski pisze:
> Jarek Poplawski pisze:
>> To David Miller:
>> since among patches tested negatively by Pawel are current 2 fixes
>> from 2.6.31-rc, I hope they weren't sent to -stable yet. Otherwise,
>> please withdraw them until they are tested alone. Thanks.
>>
>> To Pawel:
>> On Sun, Jun 28, 2009 at 05:48:19PM +0200, Pawe=B3 Staszewski wrote:
>> =20
>>> After apply this patch something is wrong
>>>
>>> Traffic is not forwarded
>>> no info in dmesg / no info from bgp
>>> and also i can't connect to bgpd process
>>>
>>> I revert kernel to past version with first Jarek patch
>>>
>>>    =20
>>
>> Since checking this can take time I attach here a patch with only
>> changes which are currently in 2.6.31-rc. Of course, this part can b=
e
>> broken as well, so it's up to you: if you could try it with caution
>> somewhere it would be very helpful; otherwise don't bother.
>>
>> It could be applied to 2.6.29 with or without this currently working
>> patch.
>>
>>  =20
>
> Ok.
> I applied this patch 15mins ago to 2.6.29.5 and now it's working -=20
> traffic is forwarded.
>
> Some fib_triestats
> cat /proc/net/fib_triestat
> Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
> Main:
>        Aver depth:     2.29
>        Max depth:      6
>        Leaves:         277015
>        Prefixes:       290493
>        Internal nodes: 67115
>          1: 35733  2: 13635  3: 9544  4: 4832  5: 2239  6: 1125  7: 5=
 =20
> 9: 1  18: 1
>        Pointers: 686614
> Null ptrs: 342485
> Total size: 18396  kB
>
> Counters:
> ---------
> gets =3D 3956301
> backtracks =3D 192497
> semantic match passed =3D 3895955
> semantic match miss =3D 133
> null node hit=3D 4306948
> skipped node resize =3D 0
>
> Local:
>        Aver depth:     3.75
>        Max depth:      5
>        Leaves:         12
>        Prefixes:       13
>        Internal nodes: 10
>          1: 9  2: 1
>        Pointers: 22
> Null ptrs: 1
> Total size: 2  kB
>
> Counters:
> ---------
> gets =3D 3960981
> backtracks =3D 2152441
> semantic match passed =3D 4757
> semantic match miss =3D 0
> null node hit=3D 194997
> skipped node resize =3D 0
>
>
>
>> Thanks,
>> Jarek P.
>> --- (for 2.6.29.x, .28 or .27)
>>
>> diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>> --- a/net/ipv4/fib_trie.c    2009-06-27 20:25:06.000000000 +0200
>> +++ b/net/ipv4/fib_trie.c    2009-06-28 23:06:02.000000000 +0200
>> @@ -123,6 +123,7 @@ struct tnode {
>>      union {
>>          struct rcu_head rcu;
>>          struct work_struct work;
>> +        struct tnode *tnode_free;
>>      };
>>      struct node *child[0];
>>  };
>> @@ -161,6 +162,8 @@ static void tnode_put_child_reorg(struct
>>  static struct node *resize(struct trie *t, struct tnode *tn);
>>  static struct tnode *inflate(struct trie *t, struct tnode *tn);
>>  static struct tnode *halve(struct trie *t, struct tnode *tn);
>> +/* tnodes to free after resize(); protected by RTNL */
>> +static struct tnode *tnode_free_head;
>> =20
>>  static struct kmem_cache *fn_alias_kmem __read_mostly;
>>  static struct kmem_cache *trie_leaf_kmem __read_mostly;
>> @@ -385,6 +388,24 @@ static inline void tnode_free(struct tno
>>          call_rcu(&tn->rcu, __tnode_free_rcu);
>>  }
>> =20
>> +static void tnode_free_safe(struct tnode *tn)
>> +{
>> +    BUG_ON(IS_LEAF(tn));
>> +    tn->tnode_free =3D tnode_free_head;
>> +    tnode_free_head =3D tn;
>> +}
>> +
>> +static void tnode_free_flush(void)
>> +{
>> +    struct tnode *tn;
>> +
>> +    while ((tn =3D tnode_free_head)) {
>> +        tnode_free_head =3D tn->tnode_free;
>> +        tn->tnode_free =3D NULL;
>> +        tnode_free(tn);
>> +    }
>> +}
>> +
>>  static struct leaf *leaf_new(void)
>>  {
>>      struct leaf *l =3D kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL)=
;
>> @@ -495,7 +516,7 @@ static struct node *resize(struct trie *
>> =20
>>      /* No children */
>>      if (tn->empty_children =3D=3D tnode_child_length(tn)) {
>> -        tnode_free(tn);
>> +        tnode_free_safe(tn);
>>          return NULL;
>>      }
>>      /* One child */
>> @@ -509,7 +530,7 @@ static struct node *resize(struct trie *
>> =20
>>              /* compress one level */
>>              node_set_parent(n, NULL);
>> -            tnode_free(tn);
>> +            tnode_free_safe(tn);
>>              return n;
>>          }
>>      /*
>> @@ -670,7 +691,7 @@ static struct node *resize(struct trie *
>>              /* compress one level */
>> =20
>>              node_set_parent(n, NULL);
>> -            tnode_free(tn);
>> +            tnode_free_safe(tn);
>>              return n;
>>          }
>> =20
>> @@ -756,7 +777,7 @@ static struct tnode *inflate(struct trie
>>              put_child(t, tn, 2*i, inode->child[0]);
>>              put_child(t, tn, 2*i+1, inode->child[1]);
>> =20
>> -            tnode_free(inode);
>> +            tnode_free_safe(inode);
>>              continue;
>>          }
>> =20
>> @@ -801,9 +822,9 @@ static struct tnode *inflate(struct trie
>>          put_child(t, tn, 2*i, resize(t, left));
>>          put_child(t, tn, 2*i+1, resize(t, right));
>> =20
>> -        tnode_free(inode);
>> +        tnode_free_safe(inode);
>>      }
>> -    tnode_free(oldtnode);
>> +    tnode_free_safe(oldtnode);
>>      return tn;
>>  nomem:
>>      {
>> @@ -885,7 +906,7 @@ static struct tnode *halve(struct trie *
>>          put_child(t, newBinNode, 1, right);
>>          put_child(t, tn, i/2, resize(t, newBinNode));
>>      }
>> -    tnode_free(oldtnode);
>> +    tnode_free_safe(oldtnode);
>>      return tn;
>>  nomem:
>>      {
>> @@ -983,12 +1004,14 @@ fib_find_node(struct trie *t, u32 key)
>>      return NULL;
>>  }
>> =20
>> -static struct node *trie_rebalance(struct trie *t, struct tnode *tn=
)
>> +static void trie_rebalance(struct trie *t, struct tnode *tn)
>>  {
>>      int wasfull;
>> -    t_key cindex, key =3D tn->key;
>> +    t_key cindex, key;
>>      struct tnode *tp;
>> =20
>> +    key =3D tn->key;
>> +
>>      while (tn !=3D NULL && (tp =3D node_parent((struct node *)tn)) =
!=3D=20
>> NULL) {
>>          cindex =3D tkey_extract_bits(key, tp->pos, tp->bits);
>>          wasfull =3D tnode_full(tp, tnode_get_child(tp, cindex));
>> @@ -998,6 +1021,7 @@ static struct node *trie_rebalance(struc
>>                        (struct node *)tn, wasfull);
>> =20
>>          tp =3D node_parent((struct node *) tn);
>> +        tnode_free_flush();
>>          if (!tp)
>>              break;
>>          tn =3D tp;
>> @@ -1007,7 +1031,10 @@ static struct node *trie_rebalance(struc
>>      if (IS_TNODE(tn))
>>          tn =3D (struct tnode *)resize(t, (struct tnode *)tn);
>> =20
>> -    return (struct node *)tn;
>> +    rcu_assign_pointer(t->trie, (struct node *)tn);
>> +    tnode_free_flush();
>> +
>> +    return;
>>  }
>> =20
>>  /* only used from updater-side */
>> @@ -1155,7 +1182,7 @@ static struct list_head *fib_insert_node
>> =20
>>      /* Rebalance the trie */
>> =20
>> -    rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
>> +    trie_rebalance(t, tp);
>>  done:
>>      return fa_head;
>>  }
>> @@ -1575,7 +1602,7 @@ static void trie_leaf_remove(struct trie
>>      if (tp) {
>>          t_key cindex =3D tkey_extract_bits(l->key, tp->pos, tp->bit=
s);
>>          put_child(t, (struct tnode *)tp, cindex, NULL);
>> -        rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
>> +        trie_rebalance(t, tp);
>>      } else
>>          rcu_assign_pointer(t->trie, NULL);
>> =20
>>
>>
>>
>>  =20
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

