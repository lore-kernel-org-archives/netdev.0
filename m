From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 9 Nov 2010 17:30:22 +1100
Message-ID: <AANLkTikAPaU_2=wS_T3V-8xFZm-G3qutJBxY8yb0QCYL@mail.gmail.com>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	<1288988955.2665.297.camel@edumazet-laptop>
	<1289213926.15004.19.camel@firesoul.comx.local>
	<1289214289.2820.188.camel@edumazet-laptop>
	<1289228785.2820.203.camel@edumazet-laptop>
	<AANLkTi=HhouZymj0R7JsDy-X1LDbfT_WL0x10EMhdOho@mail.gmail.com>
	<1289280152.2790.23.camel@edumazet-laptop>
	<1289283797.2790.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33475 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab0KIGaZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 01:30:25 -0500
Received: by fxm16 with SMTP id 16so4701135fxm.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 22:30:23 -0800 (PST)
In-Reply-To: <1289283797.2790.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

most my slowdown was kmemleak left on.

After fixing its is still a lot slower than your dev system
=2E
# time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat  127.0.0.1 9999
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB) copied, 25.8182 s, 406 MB/s

real	0m25.821s
user	0m1.502s
sys	0m33.463s

-----------------------------------------------------------------------=
-------------------------------------------
   PerfTop:     241 irqs/sec  kernel:56.8%  exact:  0.0% [1000Hz
cycles],  (all, 8 CPUs)
-----------------------------------------------------------------------=
-------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________
______________________________________

             1255.00  8.7% hpet_msi_next_event
/lib/modules/2.6.37-rc1+/build/vmlinux
             1081.00  7.5% copy_user_generic_string
/lib/modules/2.6.37-rc1+/build/vmlinux
              863.00  6.0% __ticket_spin_lock
/lib/modules/2.6.37-rc1+/build/vmlinux
              498.00  3.5% do_sys_poll
/lib/modules/2.6.37-rc1+/build/vmlinux
              455.00  3.2% system_call
/lib/modules/2.6.37-rc1+/build/vmlinux
              409.00  2.8% fget_light
/lib/modules/2.6.37-rc1+/build/vmlinux
              348.00  2.4% tcp_sendmsg
/lib/modules/2.6.37-rc1+/build/vmlinux
              269.00  1.9% fsnotify
/lib/modules/2.6.37-rc1+/build/vmlinux
              258.00  1.8% _raw_spin_unlock_irqrestore
/lib/modules/2.6.37-rc1+/build/vmlinux
              223.00  1.6% _raw_spin_lock_irqsave
/lib/modules/2.6.37-rc1+/build/vmlinux
              203.00  1.4% __clear_user
/lib/modules/2.6.37-rc1+/build/vmlinux
              184.00  1.3% tcp_poll
/lib/modules/2.6.37-rc1+/build/vmlinux
              178.00  1.2% vfs_write
/lib/modules/2.6.37-rc1+/build/vmlinux
              165.00  1.1% tcp_recvmsg
/lib/modules/2.6.37-rc1+/build/vmlinux
              152.00  1.1% pipe_read
/lib/modules/2.6.37-rc1+/build/vmlinux
              149.00  1.0% schedule
/lib/modules/2.6.37-rc1+/build/vmlinux
              135.00  0.9% rw_verify_area
/lib/modules/2.6.37-rc1+/build/vmlinux
              135.00  0.9% __pollwait
/lib/modules/2.6.37-rc1+/build/vmlinux
              130.00  0.9% __write
/lib/libc-2.12.1.so
              127.00  0.9% __ticket_spin_unlock
/lib/modules/2.6.37-rc1+/build/vmlinux
              126.00  0.9% __poll
/lib/libc-2.12.1.so


On Tue, Nov 9, 2010 at 5:23 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 09 novembre 2010 =E0 06:22 +0100, Eric Dumazet a =E9crit :
>> Le mardi 09 novembre 2010 =E0 11:05 +1100, Andrew Hendry a =E9crit :
>> > results on an i7 860 @ 2.80Ghz machine, no virtualization involved=
=2E 2.6.37-rc1+
>> >
>> > # time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat =A0127.0.0=
=2E1 9999
>> > 10000+0 records in
>> > 10000+0 records out
>> > 10485760000 bytes (10 GB) copied, 50.2022 s, 209 MB/s
>> >
>> > real =A0 =A0 =A0 =A00m50.210s
>> > user =A0 =A0 =A0 =A00m1.094s
>> > sys 0m57.589s
>>
>> Thanks !
>>
>> Could you take a pef snapshot during the test ?
>>
>> # perf record -a -g sleep 10
>> # perf report
>>
>>
>
> On my laptop
> Intel(R) Core(TM)2 Duo CPU =A0 =A0 T8300 =A0@ 2.40GHz
> (2.6.35-22-generic #35-Ubuntu SMP Sat Oct 16 20:45:36 UTC 2010 x86_64
> GNU/Linux) :
>
> time dd if=3D/dev/zero bs=3D1M count=3D10000|netcat 127.0.0.1 9999
> 10000+0 enregistrements lus
> 10000+0 enregistrements =E9crits
> 10485760000 octets (10 GB) copi=E9s, 38,2691 s, 274 MB/s
>
> real =A0 =A00m38.274s
> user =A0 =A00m1.870s
> sys =A0 =A0 0m38.370s
>
>
> perf top result :
>
> ---------------------------------------------------------------------=
----------------------------
> =A0 PerfTop: =A0 =A01948 irqs/sec =A0kernel:90.7% =A0exact: =A00.0% [=
1000Hz cycles], =A0(all, 2 CPUs)
> ---------------------------------------------------------------------=
----------------------------
>
> =A0 =A0 =A0 =A0 =A0 =A0 samples =A0pcnt function =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0DSO
> =A0 =A0 =A0 =A0 =A0 =A0 _______ _____ ___________________________ ___=
________________
>
> =A0 =A0 =A0 =A0 =A0 =A0 1867.00 12.4% copy_user_generic_string =A0 =A0=
[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 1166.00 =A07.7% __ticket_spin_lock =A0 =A0 =A0=
 =A0 =A0[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0744.00 =A04.9% __clear_user =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0667.00 =A04.4% system_call =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 [kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0329.00 =A02.2% tcp_sendmsg =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 [kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0304.00 =A02.0% schedule =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0257.00 =A01.7% _raw_spin_unlock_irqrestore=
 [kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0231.00 =A01.5% fget_light =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0216.00 =A01.4% do_poll =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 [kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0203.00 =A01.3% __read_chk =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0/lib/libc-2.12.1.so
> =A0 =A0 =A0 =A0 =A0 =A0 =A0202.00 =A01.3% __pollwait =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0201.00 =A01.3% __poll =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0/lib/libc-2.12.1.so
> =A0 =A0 =A0 =A0 =A0 =A0 =A0187.00 =A01.2% system_call_after_swapgs =A0=
 =A0[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0176.00 =A01.2% __write =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 /lib/libc-2.12.1.so
> =A0 =A0 =A0 =A0 =A0 =A0 =A0173.00 =A01.1% _raw_spin_lock_irqsave =A0 =
=A0 =A0[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0163.00 =A01.1% tcp_recvmsg =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 [kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0158.00 =A01.0% do_sys_poll =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 [kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0153.00 =A01.0% vfs_write =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 [kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0143.00 =A00.9% pipe_read =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 [kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0141.00 =A00.9% fput =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0121.00 =A00.8% common_file_perm =A0 =A0 =A0=
 =A0 =A0 =A0[kernel.kallsyms]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0120.00 =A00.8% _cond_resched =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 [kernel.kallsyms]
>
>
> # vmstat 1
> procs -----------memory---------- ---swap-- -----io---- -system-- ---=
-cpu----
> =A0r =A0b =A0 swpd =A0 free =A0 buff =A0cache =A0 si =A0 so =A0 =A0bi=
 =A0 =A0bo =A0 in =A0 cs us sy id wa
> =A02 =A00 =A0 1456 120056 =A051572 2606876 =A0 =A00 =A0 =A00 =A0 158 =
=A0 =A041 =A0254 =A0190 =A09 =A02 88 =A00
> =A02 =A00 =A0 1456 120140 =A051580 2606868 =A0 =A00 =A0 =A00 =A0 =A01=
2 =A0 =A0 0 =A0758 158309 11 76 13 =A00
> =A02 =A00 =A0 1456 119520 =A051588 2606896 =A0 =A00 =A0 =A00 =A0 =A0 =
0 =A0 176 =A0778 160749 =A08 80 12 =A00
> =A02 =A00 =A0 1456 120388 =A051588 2606896 =A0 =A00 =A0 =A00 =A0 =A0 =
0 =A0 =A0 0 =A0730 158201 =A09 76 16 =A00
> =A03 =A00 =A0 1456 120388 =A051588 2606896 =A0 =A00 =A0 =A00 =A0 =A0 =
0 =A0 =A0 0 =A0745 158490 =A08 76 16 =A00
> =A02 =A00 =A0 1456 120520 =A051588 2606896 =A0 =A00 =A0 =A00 =A0 =A0 =
0 =A0 =A0 0 =A0991 159120 =A09 78 13 =A00
> =A02 =A00 =A0 1456 120024 =A051588 2606896 =A0 =A00 =A0 =A00 =A0 =A0 =
0 =A0 =A0 0 =A0653 160023 10 79 11 =A00
> =A03 =A00 =A0 1456 120520 =A051588 2606896 =A0 =A00 =A0 =A00 =A0 =A0 =
0 =A0 =A0 0 =A0659 160614 =A08 78 14 =A00
> =A02 =A00 =A0 1456 120272 =A051596 2606896 =A0 =A00 =A0 =A00 =A0 =A0 =
0 =A0 =A080 =A0695 159922 10 75 14 =A00
> =A04 =A00 =A0 1456 120272 =A051596 2606896 =A0 =A00 =A0 =A00 =A0 =A0 =
0 =A0 =A0 0 =A0675 158010 =A07 79 14 =A00
>
>
> # powertop
> =A0 =A0 PowerTOP version 1.13 =A0 =A0 =A0(C) 2007 Intel Corporation
>
> < Detailed C-state information is not P-states (frequencies)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0Turbo Mode =A0 =A043.1%
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A02.40 Ghz =A0 =A048.0%
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A02.00 Ghz =A0 =A0 8.2%
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A01.60 Ghz =A0 =A0 0.7%
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A01200 Mhz =A0 =A0 0.1%
>
> Wakeups-from-idle per second : 542.9 =A0 =A0interval: 10.0s
> no ACPI power usage estimate available
>
> Top causes for wakeups:
> =A021.9% (196.5) =A0 [kernel scheduler] Load balancing tick
> =A021.2% (190.7) =A0 [Rescheduling interrupts] <kernel IPI>
> =A012.7% (114.0) =A0 PS/2 keyboard/mouse/touchpad interrupt
> =A012.0% (107.9) =A0 plugin-containe
> =A011.1% ( 99.3) =A0 alsa-sink
> =A0 6.0% ( 53.8) =A0 firefox-bin
> =A0 4.4% ( 39.7) =A0 fping
> =A0 3.9% ( 35.2) =A0 Xorg
> =A0 1.3% ( 11.3) =A0 [b43] <interrupt>
> =A0 1.1% ( 10.0) =A0 ksoftirqd/0
> =A0 0.4% ( =A04.0)D =A0nagios3
> =A0 0.2% ( =A01.9)D =A0gnome-terminal
> =A0 0.7% ( =A06.4) =A0 [Thermal event interrupts] <kernel IPI>
>
>
>
>
