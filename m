From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 0% cpu usasge after fresh boot or net restart but 10% CPU if
 kernel flush route cache
Date: Thu, 28 Jan 2010 18:06:20 +0100
Message-ID: <1264698380.2930.20.camel@edumazet-laptop>
References: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
	 <1264605976.3197.8.camel@edumazet-laptop>
	 <41ac0f9e1001271153u333a5e2aq6f473ccc6e6d1e23@mail.gmail.com>
	 <1264627088.2892.7.camel@edumazet-laptop>
	 <41ac0f9e1001280114x17951046oda3fddcae4b8b9d3@mail.gmail.com>
	 <1264694957.2930.15.camel@edumazet-laptop>
	 <41ac0f9e1001280826j1a4e6caar47ccfd357b6feb37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: cold cold <nedkonedev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:34609 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755995Ab0A1RG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 12:06:28 -0500
Received: by bwz27 with SMTP id 27so685944bwz.21
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 09:06:27 -0800 (PST)
In-Reply-To: <41ac0f9e1001280826j1a4e6caar47ccfd357b6feb37@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 janvier 2010 =C3=A0 18:26 +0200, cold cold a =C3=A9crit :
> On Thu, Jan 28, 2010 at 6:09 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le jeudi 28 janvier 2010 =C3=A0 11:14 +0200, cold cold a =C3=A9crit=
 :
> >
> >>
> >> RX Kpps : 57 TX Kpps : 53  RX Kbits : 331184 TX Kbits : 306213
> >> RX Kpps : 59 TX Kpps : 54  RX Kbits : 345517 TX Kbits : 304323
> >> RX Kpps : 56 TX Kpps : 52  RX Kbits : 331418 TX Kbits : 296032
> >> RX Kpps : 60 TX Kpps : 54  RX Kbits : 362007 TX Kbits : 297371
> >> RX Kpps : 59 TX Kpps : 52  RX Kbits : 360455 TX Kbits : 280603
> >>
> >>
> >> ON  one cpu, gc_interval to 1, gc_elasticity 2
> >>
> >> Cpu0  :  0.0%us,  0.0%sy,  0.0%ni, 72.0%id,  0.0%wa,  8.3%hi, 19.7=
%si,  0.0%st
> >> Cpu1  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0=
%si,  0.0%st
> >> Cpu2  :  0.0%us,  0.3%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.0=
%si,  0.0%st
> >> Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0=
%si,  0.0%st
> >>
> >> ------------------------------------------------------------------=
------------
> >>    PerfTop:   17064 irqs/sec  kernel:98.0% [100000 cycles],  (all,=
 4 CPUs)
> >> ------------------------------------------------------------------=
------------
> >>
> >>              samples    pcnt   kernel function
> >>              _______   _____   _______________
> >>
> >>             40388.00 - 27.8% : acpi_idle_do_entry
> >>             24651.00 - 17.0% : read_hpet
> >>              4271.00 -  2.9% : _spin_lock
> >>              3388.00 -  2.3% : pskb_expand_head
> >>              3288.00 -  2.3% : igb_poll [igb]
> >>              3246.00 -  2.2% : irq_entries_start
> >>              2868.00 -  2.0% : dev_gro_receive
> >>              2665.00 -  1.8% : igb_xmit_frame_adv       [igb]
> >>              2513.00 -  1.7% : ip_route_input
> >>              2144.00 -  1.5% : igb_clean_tx_irq [igb]
> >>              1842.00 -  1.3% : __slab_free
> >>              1544.00 -  1.1% : dev_queue_xmit
> >>              1423.00 -  1.0% : igb_msix_rx      [igb]
> >>              1353.00 -  0.9% : __alloc_skb
> >>              1285.00 -  0.9% : eth_type_trans
> >> --
> >
> > All this seems pretty normal profile (regarding networking function=
s),
> > your machine should scale without problem.
> >
> > Of course, the two first functions (acpi_idle_do_entry() & read_hpe=
t())
> > look suspicious but I have no idea why.
> >
>=20
> i make with flushing without gc on 2 cpu  2 time more traffic  and CP=
U
> usage about 5 times less
>=20
> top - 11:22:04 up  6:45,  5 users,  load average: 0.00, 0.10, 0.25
> Tasks:  84 total,   1 running,  83 sleeping,   0 stopped,   0 zombie
> Cpu0  :  0.0%us,  0.3%sy,  0.0%ni, 94.0%id,  0.0%wa,  1.7%hi,  4.0%si=
,  0.0%st
> Cpu1  :  0.3%us,  0.0%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.7%hi,  1.3%si=
,  0.0%st
> Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
>=20

pure luck I guess, since you use two cpus here instead of one, but
nothing guarantee this.

>=20
> RX Kpps : 90 TX Kpps : 75  RX Kbits : 582791 TX Kbits : 413873
> RX Kpps : 87 TX Kpps : 74  RX Kbits : 546327 TX Kbits : 415852
> RX Kpps : 87 TX Kpps : 74  RX Kbits : 544820 TX Kbits : 418339
> RX Kpps : 88 TX Kpps : 73  RX Kbits : 569143 TX Kbits : 406438
> --

Not sure I understand your goals. Previous numbers were with less
trafic ?

What do you want ? your cpus being idle, or your router being able to
forward packets without drops ?

Good, but if you drop packets when real garbage collection is done, you
loose. Make your choice :)



