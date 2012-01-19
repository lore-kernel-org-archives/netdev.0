From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Interpreting perf stat on netperf and netserver
Date: Thu, 19 Jan 2012 11:26:34 +0100
Message-ID: <CAL8zT=hr6vf3tUFaxH_Qk8E3HPd6=WNjrHeMLph2e54sagu37w@mail.gmail.com>
References: <CAL8zT=gNwDDXcbH+hoZApc63ArW2quzHJ1gRrPSxKP7jE04KLw@mail.gmail.com>
 <1326965048.2249.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:52441 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755441Ab2ASK04 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 05:26:56 -0500
Received: by wics10 with SMTP id s10so234582wic.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 02:26:55 -0800 (PST)
In-Reply-To: <1326965048.2249.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/19 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mercredi 18 janvier 2012 =C3=A0 12:33 +0100, Jean-Michel Hautbois =
a
> =C3=A9crit :
>
>> The be2net driver seems to have difficulties woth IRQ affinity also,
>> because it always uses CPU0 even if the affinity is 0-23 !
>> netperf result is quite good, and perf top shows :
>> =C2=A0 =C2=A0PerfTop: =C2=A0 =C2=A0 689 irqs/sec =C2=A0kernel:99.6% =
us: 0.3% guest kernel: 0.0%
>> guest us: 0.0% exact: =C2=A00.0% [1000Hz cycles], =C2=A0(all, 24 CPU=
s)
>> --------------------------------------------------------------------=
-----------------------------------------------------------------------=
---------------------------------------
>>
>> =C2=A0 =C2=A0 29.28% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
[k] csum_partial
>> =C2=A0 =C2=A0 =C2=A08.46% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] copy_user_generic_string
>> =C2=A0 =C2=A0 =C2=A03.70% =C2=A0[be2net] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] be_poll_rx
>> =C2=A0 =C2=A0 =C2=A03.08% =C2=A0[be2net] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] event_handle
>> =C2=A0 =C2=A0 =C2=A02.37% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] irq_entries_start
>> =C2=A0 =C2=A0 =C2=A02.21% =C2=A0[be2net] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] be_rx_compl_get
>> =C2=A0 =C2=A0 =C2=A01.65% =C2=A0[be2net] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] be_post_rx_frags
>> =C2=A0 =C2=A0 =C2=A01.64% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] __napi_complete
>> =C2=A0 =C2=A0 =C2=A01.50% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] ip_defrag
>> =C2=A0 =C2=A0 =C2=A01.35% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] put_page
>> =C2=A0 =C2=A0 =C2=A01.34% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] get_page_from_freelist
>> =C2=A0 =C2=A0 =C2=A01.29% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] __netif_receive_skb
>> =C2=A0 =C2=A0 =C2=A01.16% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] __alloc_pages_nodemask
>> =C2=A0 =C2=A0 =C2=A01.14% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] debug_smp_processor_id
>> =C2=A0 =C2=A0 =C2=A01.08% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] add_preempt_count
>> =C2=A0 =C2=A0 =C2=A01.06% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] sub_preempt_count
>> =C2=A0 =C2=A0 =C2=A01.03% =C2=A0[be2net] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] get_rx_page_info
>> =C2=A0 =C2=A0 =C2=A01.01% =C2=A0[kernel] =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0[k] alloc_pages_current
>>
>> Checksum calculation seems quite complex :).
>
> UDP with fragments... I guess... but cant see this in the perf top
> output ;)
>
> What bandwidth do you get for this cpu load ?

Yes, this was UDP fragmentation :). I had 6800Mbps for a theoretical
limit of 7000Mbps (Flex 10Gbps system).

JM
