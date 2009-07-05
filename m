From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Mon, 06 Jul 2009 01:53:49 +0200
Message-ID: <4A513D0D.5070204@itcare.pl>
References: <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <4A4FF40B.5090003@itcare.pl> <20090705162003.GA19477@ami.dom.local> <20090705173208.GB19477@ami.dom.local> <20090705213232.GG8943@linux.vnet.ibm.com> <20090705222301.GA3203@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:55272 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755030AbZGEXxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2009 19:53:49 -0400
In-Reply-To: <20090705222301.GA3203@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kernel 2.6.29.5 preempt
bgp starts normal and kernel know routes normaly like without patch

Here are some fib_triestats

cat /proc/net/fib_triestat
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.44
        Max depth:      6
        Leaves:         277888
        Prefixes:       291399
        Internal nodes: 66818
          1: 33080  2: 14584  3: 10788  4: 4911  5: 2185  6: 900  7:=20
366  8: 3  17: 1
        Pointers: 595584
Null ptrs: 250879
Total size: 18072  kB

Counters:
---------
gets =3D 1052940
backtracks =3D 55985
semantic match passed =3D 1034114
semantic match miss =3D 5
null node hit=3D 534415
skipped node resize =3D 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets =3D 1057636
backtracks =3D 1101307
semantic match passed =3D 4751
semantic match miss =3D 0
null node hit=3D 195605
skipped node resize =3D 0




kernel 2.6.29.5 no-preempt
All is ok like with preempt kernel (andl all working in normal time=20
"routes propagation")

cat /sys/module/fib_trie/parameters/sync_pages
1000


cat /proc/net/fib_triestat
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.45
        Max depth:      6
        Leaves:         277905
        Prefixes:       291416
        Internal nodes: 66863
          1: 33119  2: 14594  3: 10782  4: 4911  5: 2187  6: 901  7:=20
365  8: 3  17: 1
        Pointers: 595654
Null ptrs: 250887
Total size: 18074  kB

Counters:
---------
gets =3D 1060650
backtracks =3D 53161
semantic match passed =3D 1041008
semantic match miss =3D 12
null node hit=3D 504478
skipped node resize =3D 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets =3D 1065517
backtracks =3D 1095422
semantic match passed =3D 4954
semantic match miss =3D 0
null node hit=3D 195584
skipped node resize =3D 0

So i make tests with changing sync_pages
And

####################################
sync_pages: 64
total size reach maximum in 17sec

Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.43
        Max depth:      6
        Leaves:         271928
        Prefixes:       285435
        Internal nodes: 66185
          1: 32904  2: 14554  3: 10740  4: 4677  5: 2047  6: 901  7:=20
361  17: 1
        Pointers: 585224
Null ptrs: 247112
Total size: 17729  kB

Counters:
---------
gets =3D 5313544
backtracks =3D 230501
semantic match passed =3D 5233998
semantic match miss =3D 61
null node hit=3D 2757531
skipped node resize =3D 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets =3D 5332471
backtracks =3D 4708505
semantic match passed =3D 19264
semantic match miss =3D 0
null node hit=3D 782757
skipped node resize =3D 0



######################################
sync_pages: 128
=46ib trie Total size reach max in 14sec
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.44
        Max depth:      6
        Leaves:         277915
        Prefixes:       291427
        Internal nodes: 66832
          1: 33085  2: 14597  3: 10785  4: 4908  5: 2187  6: 900  7:=20
366  8: 3  17: 1
        Pointers: 595638
Null ptrs: 250892
Total size: 18074  kB

Counters:
---------
gets =3D 6698058
backtracks =3D 307491
semantic match passed =3D 6593421
semantic match miss =3D 66
null node hit=3D 3498560
skipped node resize =3D 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets =3D 6721120
backtracks =3D 5934017
semantic match passed =3D 23440
semantic match miss =3D 0
null node hit=3D 978008
skipped node resize =3D 0

#########################################
sync_pages: 256
hmm no difference also in 10sec

Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.44
        Max depth:      6
        Leaves:         277913
        Prefixes:       291425
        Internal nodes: 66829
          1: 33082  2: 14596  3: 10786  4: 4909  5: 2186  6: 900  7:=20
366  8: 3  17: 1
        Pointers: 595620
Null ptrs: 250879
Total size: 18073  kB

Counters:
---------
gets =3D 4637474
backtracks =3D 188624
semantic match passed =3D 4577266
semantic match miss =3D 61
null node hit=3D 2451890
skipped node resize =3D 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets =3D 4651791
backtracks =3D 3716400
semantic match passed =3D 14613
semantic match miss =3D 0
null node hit=3D 587208
skipped node resize =3D 0


And with sync_pages higher that 256 time of filling kernel routes is th=
e=20
same approx 10sec.


I make this test bu use:
watch -n1 cat /proc/net/fib_triestat
timer start when Total size was 1kB and stop when Total size reach 1807=
3  kB


Regards
Pawe=B3 Staszewski

Jarek Poplawski pisze:
> On Sun, Jul 05, 2009 at 02:32:32PM -0700, Paul E. McKenney wrote:
>  =20
>> On Sun, Jul 05, 2009 at 07:32:08PM +0200, Jarek Poplawski wrote:
>>    =20
>>> On Sun, Jul 05, 2009 at 06:20:03PM +0200, Jarek Poplawski wrote:
>>>      =20
>>>> On Sun, Jul 05, 2009 at 02:30:03AM +0200, Pawe=B3 Staszewski wrote=
:
>>>>        =20
>>>>> Oh
>>>>>
>>>>> I forgot - please Jarek give me patch with sync rcu and i will ma=
ke test =20
>>>>> on preempt kernel
>>>>>          =20
>>>> Probably non-preempt kernel might need something like this more, b=
ut
>>>> comparing is always interesting. This patch is based on Paul's
>>>> suggestion (I hope).
>>>>        =20
>>> Hold on ;-) Here is something even better... Syncing after 128 page=
s
>>> might be still too slow, so here is a higher initial value, 1000, p=
lus
>>> you can change this while testing in:
>>>
>>> /sys/module/fib_trie/parameters/sync_pages
>>>
>>> It would be interesting to find the lowest acceptable value.
>>>      =20
>> Looks like a promising approach to me!
>>
>> 							Thanx, Paul
>>    =20
>
> Hmm... As a matter of fact, I'm a bit sceptical now: I'm worrying thi=
s
> synchronize_rcu done at the lowest acceptable rate could be actually
> mostly idle or on the contrary too late. Probably some more complex
> (per cpu?) accounting would be necessary to really matter here, but
> on the other hand these problems weren't reported often enough.
>
> Thanks,
> Jarek P.
>
>  =20
>>> ---> (synchronize take 8; apply on top of the 2.6.29.x with the las=
t
>>>  	all-in-one patch, or net-2.6)
>>>
>>>  net/ipv4/fib_trie.c |   12 ++++++++++++
>>>  1 files changed, 12 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>>> index 00a54b2..decc8d0 100644
>>> --- a/net/ipv4/fib_trie.c
>>> +++ b/net/ipv4/fib_trie.c
>>> @@ -71,6 +71,7 @@
>>>  #include <linux/netlink.h>
>>>  #include <linux/init.h>
>>>  #include <linux/list.h>
>>> +#include <linux/moduleparam.h>
>>>  #include <net/net_namespace.h>
>>>  #include <net/ip.h>
>>>  #include <net/protocol.h>
>>> @@ -164,6 +165,10 @@ static struct tnode *inflate(struct trie *t, s=
truct tnode *tn);
>>>  static struct tnode *halve(struct trie *t, struct tnode *tn);
>>>  /* tnodes to free after resize(); protected by RTNL */
>>>  static struct tnode *tnode_free_head;
>>> +static size_t tnode_free_size;
>>> +
>>> +static int sync_pages __read_mostly =3D 1000;
>>> +module_param(sync_pages, int, 0640);
>>>
>>>  static struct kmem_cache *fn_alias_kmem __read_mostly;
>>>  static struct kmem_cache *trie_leaf_kmem __read_mostly;
>>> @@ -393,6 +398,8 @@ static void tnode_free_safe(struct tnode *tn)
>>>  	BUG_ON(IS_LEAF(tn));
>>>  	tn->tnode_free =3D tnode_free_head;
>>>  	tnode_free_head =3D tn;
>>> +	tnode_free_size +=3D sizeof(struct tnode) +
>>> +			   (sizeof(struct node *) << tn->bits);
>>>  }
>>>
>>>  static void tnode_free_flush(void)
>>> @@ -404,6 +411,11 @@ static void tnode_free_flush(void)
>>>  		tn->tnode_free =3D NULL;
>>>  		tnode_free(tn);
>>>  	}
>>> +
>>> +	if (tnode_free_size >=3D PAGE_SIZE * sync_pages) {
>>> +		tnode_free_size =3D 0;
>>> +		synchronize_rcu();
>>> +	}
>>>  }
>>>
>>>  static struct leaf *leaf_new(void)
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>      =20
>
>
>  =20

