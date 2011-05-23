From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: 2.6.38.x, 2.6.39 =?UTF-8?Q?sfq=3F=20kernel=20panic=20in=20sfq?=  =?UTF-8?Q?=5Fenqueue?=
Date: Mon, 23 May 2011 17:27:41 +0300
Message-ID: <47b6835144d208dca4c6675f6510fcad@visp.net.lb>
References: <598fe111e91c6236b8bfdfca323b9a17@visp.net.lb>
 <1306153938.20687.2.camel@edumazet-laptop>
 <1306155058.20687.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <hadi@cyberus.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:42475 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755628Ab1EWO1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 10:27:44 -0400
In-Reply-To: <1306155058.20687.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Mon, 23 May 2011 14:50:58 +0200, Eric Dumazet wrote:
>
> Oh well, false alarm, I am still trying to understand the case.
>
> Some other reports would be appreciated, because here is the strange
> thing :
>
> [ 4461.969603] Code: b6 70 10
> 3b b3 08 01 00 00
> 0f 8d df 01 00 00 jge ....
>
> 41 8b 74 24 28    mov 0x28(%r12),%esi       qdisc_pkt_len(skb)
> 01 b3 b4 00 00 00                       sch->qstats.backlog +=
> qdisc_pkt_len(skb);
>
> RAX = slot
> R12 = SKB
>
> 48 8b 70 08       mov    0x8(%rax),%rsi     slot->skblist_prev
> 49 89 04 24       mov    %rax,(%r12)        skb->next = (struct
> sk_buff *)slot;
> 49 89 74 24 08    mov    %rsi,0x8(%r12)     skb->prev = 
> slot->skblist_prev;
> 48 8b 70 08       mov    0x8(%rax),%rsi     slot->skblist_prev   
> (refetch)
>
> <4c> 89 26        mov    %r12,(%rsi)         slot->skblist_prev->next
> = skb;  // CRASH
>
> 0f b6 f2          movzbl %dl,%esi
> 4c 89 60 08       mov    %r12,0x8(%rax)      slot->skblist_prev = 
> skb;
> 48 8d 3c 76       lea
> 48 8d bc fb 90 01 00
>
>
>
> And in your report RAX = R12 !!! (ffff8801172a7d08) I cant see how it
> can happen (Its not even a valid skb address, since an SKB should be
> 64bytes aligned)
>
> If available a disassembly of sfq_enqueue() would be appreciated too 
> ;)
>
> Thanks !
 By objdump or he must recompile kernel with DEBUG_INFO and use gdb?



