From: cold cold <nedkonedev@gmail.com>
Subject: Re: 0% cpu usasge after fresh boot or net restart but 10% CPU if
	kernel flush route cache
Date: Thu, 28 Jan 2010 20:49:28 +0200
Message-ID: <41ac0f9e1001281049g119d5b1bgbc47f78150cac6ee@mail.gmail.com>
References: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
	 <1264605976.3197.8.camel@edumazet-laptop>
	 <41ac0f9e1001271153u333a5e2aq6f473ccc6e6d1e23@mail.gmail.com>
	 <1264627088.2892.7.camel@edumazet-laptop>
	 <41ac0f9e1001280114x17951046oda3fddcae4b8b9d3@mail.gmail.com>
	 <1264694957.2930.15.camel@edumazet-laptop>
	 <41ac0f9e1001280826j1a4e6caar47ccfd357b6feb37@mail.gmail.com>
	 <1264698380.2930.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:41155 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755441Ab0A1S4F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 13:56:05 -0500
Received: by fxm7 with SMTP id 7so1210746fxm.28
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 10:56:04 -0800 (PST)
In-Reply-To: <1264698380.2930.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2010 at 7:06 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 28 janvier 2010 =E0 18:26 +0200, cold cold a =E9crit :
>> On Thu, Jan 28, 2010 at 6:09 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > Le jeudi 28 janvier 2010 =E0 11:14 +0200, cold cold a =E9crit :
>> >
>> >>
>> >> RX Kpps : 57 TX Kpps : 53 =A0RX Kbits : 331184 TX Kbits : 306213
>> >> RX Kpps : 59 TX Kpps : 54 =A0RX Kbits : 345517 TX Kbits : 304323
>> >> RX Kpps : 56 TX Kpps : 52 =A0RX Kbits : 331418 TX Kbits : 296032
>> >> RX Kpps : 60 TX Kpps : 54 =A0RX Kbits : 362007 TX Kbits : 297371
>> >> RX Kpps : 59 TX Kpps : 52 =A0RX Kbits : 360455 TX Kbits : 280603
>> >>
>> >>
>> >> ON =A0one cpu, gc_interval to 1, gc_elasticity 2
>> >>
>> >> Cpu0 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 72.0%id, =A00.0%wa, =A0=
8.3%hi, 19.7%si, =A00.0%st
>> >> Cpu1 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni,100.0%id, =A00.0%wa, =A0=
0.0%hi, =A00.0%si, =A00.0%st
>> >> Cpu2 =A0: =A00.0%us, =A00.3%sy, =A00.0%ni, 99.7%id, =A00.0%wa, =A0=
0.0%hi, =A00.0%si, =A00.0%st
>> >> Cpu3 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni,100.0%id, =A00.0%wa, =A0=
0.0%hi, =A00.0%si, =A00.0%st
>> >>
>> >> -----------------------------------------------------------------=
-------------
>> >> =A0 =A0PerfTop: =A0 17064 irqs/sec =A0kernel:98.0% [100000 cycles=
], =A0(all, 4 CPUs)
>> >> -----------------------------------------------------------------=
-------------
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0samples =A0 =A0pcnt =A0 kernel functio=
n
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0_______ =A0 _____ =A0 _______________
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 40388.00 - 27.8% : acpi_idle_do_entry
>> >> =A0 =A0 =A0 =A0 =A0 =A0 24651.00 - 17.0% : read_hpet
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A04271.00 - =A02.9% : _spin_lock
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A03388.00 - =A02.3% : pskb_expand_head
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A03288.00 - =A02.3% : igb_poll [igb]
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A03246.00 - =A02.2% : irq_entries_start
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A02868.00 - =A02.0% : dev_gro_receive
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A02665.00 - =A01.8% : igb_xmit_frame_adv=
 =A0 =A0 =A0 [igb]
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A02513.00 - =A01.7% : ip_route_input
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A02144.00 - =A01.5% : igb_clean_tx_irq [=
igb]
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A01842.00 - =A01.3% : __slab_free
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A01544.00 - =A01.1% : dev_queue_xmit
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A01423.00 - =A01.0% : igb_msix_rx =A0 =A0=
 =A0[igb]
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A01353.00 - =A00.9% : __alloc_skb
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A01285.00 - =A00.9% : eth_type_trans
>> >> --
>> >
>> > All this seems pretty normal profile (regarding networking functio=
ns),
>> > your machine should scale without problem.
>> >
>> > Of course, the two first functions (acpi_idle_do_entry() & read_hp=
et())
>> > look suspicious but I have no idea why.
>> >
>>
>> i make with flushing without gc on 2 cpu =A02 time more traffic =A0a=
nd CPU
>> usage about 5 times less
>>
>> top - 11:22:04 up =A06:45, =A05 users, =A0load average: 0.00, 0.10, =
0.25
>> Tasks: =A084 total, =A0 1 running, =A083 sleeping, =A0 0 stopped, =A0=
 0 zombie
>> Cpu0 =A0: =A00.0%us, =A00.3%sy, =A00.0%ni, 94.0%id, =A00.0%wa, =A01.=
7%hi, =A04.0%si, =A00.0%st
>> Cpu1 =A0: =A00.3%us, =A00.0%sy, =A00.0%ni, 97.7%id, =A00.0%wa, =A00.=
7%hi, =A01.3%si, =A00.0%st
>> Cpu2 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni,100.0%id, =A00.0%wa, =A00.=
0%hi, =A00.0%si, =A00.0%st
>> Cpu3 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni,100.0%id, =A00.0%wa, =A00.=
0%hi, =A00.0%si, =A00.0%st
>>
>
> pure luck I guess, since you use two cpus here instead of one, but
> nothing guarantee this.
>
>>
>> RX Kpps : 90 TX Kpps : 75 =A0RX Kbits : 582791 TX Kbits : 413873
>> RX Kpps : 87 TX Kpps : 74 =A0RX Kbits : 546327 TX Kbits : 415852
>> RX Kpps : 87 TX Kpps : 74 =A0RX Kbits : 544820 TX Kbits : 418339
>> RX Kpps : 88 TX Kpps : 73 =A0RX Kbits : 569143 TX Kbits : 406438
>> --
>
> Not sure I understand your goals. Previous numbers were with less
> trafic ?
>
> What do you want ? your cpus being idle, or your router being able to
> forward packets without drops ?
>
> Good, but if you drop packets when real garbage collection is done, y=
ou
> loose. Make your choice :)
>
>

what you mean drop packets ?

i test 2 different things and shearing results with you
first test with high CPU is with garbage collection function
second results represent CPU usage with totally disabled  garbage colle=
ction
