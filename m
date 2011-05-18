From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Bug, kernel panic, NULL dereference , =?UTF-8?Q?cleanup=5Fonc?=  =?UTF-8?Q?e=20/=20icmp=5Froute=5Flookup=2Eclone=2E=31=39=2Eclone=20/=20na?=  =?UTF-8?Q?t=20=2C=20=32=2E=36=2E=33=39-rc=37-git=31=31?=
Date: Wed, 18 May 2011 12:53:33 +0300
Message-ID: <0a630bbf006d1210220a6ba4d55c5804@visp.net.lb>
References: <54ec5cd14e5e5c76aa06c2e6899299ce@visp.net.lb>
 <41a1892fed59b411bb08d3ecb0d8cda5@visp.net.lb>
 <1305711471.2983.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:48257 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752467Ab1ERJxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 05:53:37 -0400
In-Reply-To: <1305711471.2983.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Wed, 18 May 2011 11:37:51 +0200, Eric Dumazet wrote:
> Le mercredi 18 mai 2011 =C3=A0 12:27 +0300, Denys Fedoryshchenko a =C3=
=A9crit :
>> On Wed, 18 May 2011 01:16:29 +0300, Denys Fedoryshchenko wrote:
>> > Just got recently. 32Bit, PPPoE NAS, shapers, firewall, NAT
>> > Kernel i mention in subject, 2.6.39-rc7-git11
>> > If required i can give more information
>> >
>> > sharanal (sorry for ugly name) is libpcap based traffic analyser,
>> > sure userspace
>> >
>>  Here is some info, i hope it will be a little useful
>>
>>  (gdb)  l *(cleanup_once + 0x49)
>>  0xc02e85cc is in cleanup_once (include/linux/list.h:88).
>>  83       * This is only for internal list manipulation where we=20
>> know
>>  84       * the prev/next entries already!
>>  85       */
>>  86      static inline void __list_del(struct list_head * prev,=20
>> struct
>>  list_head * next)
>>  87      {
>>  88              next->prev =3D prev;
>>  89              prev->next =3D next;
>>  90      }
>>  91
>>  92      /**
>>
>>  (gdb)  l *(inet_getpeer + 0x2ab)
>>  0xc02e8ae8 is in inet_getpeer (net/ipv4/inetpeer.c:530).
>>  525             if (base->total >=3D inet_peer_threshold)
>>  526                     /* Remove one less-recently-used entry. */
>>  527                     cleanup_once(0, stack);
>>  528
>>  529             return p;
>>  530     }
>>  531
>>  532     static int compute_total(void)
>>  533     {
>>  534             return v4_peers.total + v6_peers.total;
>>
>
> I really begin to think we have a bug here...
>
> In previous reports, I suggested to use slub_nomerge because I=20
> thought
> one corruption from another kernel layer was going on.
>
> (inetpeer was using 64 bytes objects). But now that inetpeer objects=20
> are
> bigger and sit in another kmemcache, its bad news.
>
> Could you try this, and eventually add some SLUB debugging stuff as
> well ?

 Yes, i will try. I should enable SLUB debugging only, or also anything=
=20
 else?

 But possible it will take time to reproduce bug, seems it is occuring=20
 rare. With 2.6.39 release i will rollout update to few hundreds PPPoE'=
s,=20
 maybe it will increase chances to get information.

