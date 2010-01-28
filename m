From: cold cold <nedkonedev@gmail.com>
Subject: Re: 0% cpu usasge after fresh boot or net restart but 10% CPU if
	kernel flush route cache
Date: Thu, 28 Jan 2010 11:14:27 +0200
Message-ID: <41ac0f9e1001280114x17951046oda3fddcae4b8b9d3@mail.gmail.com>
References: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
	 <1264605976.3197.8.camel@edumazet-laptop>
	 <41ac0f9e1001271153u333a5e2aq6f473ccc6e6d1e23@mail.gmail.com>
	 <1264627088.2892.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:42452 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754950Ab0A1JO3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 04:14:29 -0500
Received: by ewy19 with SMTP id 19so495933ewy.21
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 01:14:27 -0800 (PST)
In-Reply-To: <1264627088.2892.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2010 at 11:18 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mercredi 27 janvier 2010 =E0 21:53 +0200, cold cold a =E9crit :
>
>>
>> btw atm i have 1k ip on that router but plan to put 10k so route cac=
he
>> will grow 10 time fast.
>> i try to keep low =A0rhash_entries but garbage collector =A0is non s=
top
>> running and eat CPU
>> atm i have around 7k =A0entries per second for second for first minu=
te.
>>
>> i think it will be better if i flush cache on secret interval instea=
d
>> of giving work to gc.
>> i test with 512MB cache and CPU is 0% and flushing entire hash dont =
take a lot,
>> I'm not sure is there some side effects from flushing.
>
> Flush is immediate, it only marks entries as invalid and they are
> cleaned up later.
>
> 512 MB cache is quite small for your needs, each entry uses 384 bytes
> (assuming you use a 64bit kernel)
>
> In my experiments, I found using gc (and no flushing) was the most
> reliable way to have an equilibrium.
>
> WHen setting gc_interval to 1, =A0the garbage collector is fired ever=
y
> second and handles 1/300 of entries, from a work queue (thus doesnt s=
top
> packets to be handled by irqs), in a smooth way.
>
> You can post "perf top" results to check where cpu is consumed.
>
>
>

RX Kpps : 57 TX Kpps : 53  RX Kbits : 331184 TX Kbits : 306213
RX Kpps : 59 TX Kpps : 54  RX Kbits : 345517 TX Kbits : 304323
RX Kpps : 56 TX Kpps : 52  RX Kbits : 331418 TX Kbits : 296032
RX Kpps : 60 TX Kpps : 54  RX Kbits : 362007 TX Kbits : 297371
RX Kpps : 59 TX Kpps : 52  RX Kbits : 360455 TX Kbits : 280603


ON  one cpu, gc_interval to 1, gc_elasticity 2

Cpu0  :  0.0%us,  0.0%sy,  0.0%ni, 72.0%id,  0.0%wa,  8.3%hi, 19.7%si, =
 0.0%st
Cpu1  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu2  :  0.0%us,  0.3%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st

-----------------------------------------------------------------------=
-------
   PerfTop:   17064 irqs/sec  kernel:98.0% [100000 cycles],  (all, 4 CP=
Us)
-----------------------------------------------------------------------=
-------

             samples    pcnt   kernel function
             _______   _____   _______________

            40388.00 - 27.8% : acpi_idle_do_entry
            24651.00 - 17.0% : read_hpet
             4271.00 -  2.9% : _spin_lock
             3388.00 -  2.3% : pskb_expand_head
             3288.00 -  2.3% : igb_poll [igb]
             3246.00 -  2.2% : irq_entries_start
             2868.00 -  2.0% : dev_gro_receive
             2665.00 -  1.8% : igb_xmit_frame_adv       [igb]
             2513.00 -  1.7% : ip_route_input
             2144.00 -  1.5% : igb_clean_tx_irq [igb]
             1842.00 -  1.3% : __slab_free
             1544.00 -  1.1% : dev_queue_xmit
             1423.00 -  1.0% : igb_msix_rx      [igb]
             1353.00 -  0.9% : __alloc_skb
             1285.00 -  0.9% : eth_type_trans
