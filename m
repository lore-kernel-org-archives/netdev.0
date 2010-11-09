From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 09 Nov 2010 07:23:17 +0100
Message-ID: <1289283797.2790.84.camel@edumazet-laptop>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <AANLkTi=HhouZymj0R7JsDy-X1LDbfT_WL0x10EMhdOho@mail.gmail.com>
	 <1289280152.2790.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55740 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629Ab0KIGXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 01:23:30 -0500
Received: by wyb36 with SMTP id 36so4461432wyb.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 22:23:29 -0800 (PST)
In-Reply-To: <1289280152.2790.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 06:22 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le mardi 09 novembre 2010 =C3=A0 11:05 +1100, Andrew Hendry a =C3=A9c=
rit :
> > results on an i7 860 @ 2.80Ghz machine, no virtualization involved.=
 2.6.37-rc1+
> >=20
> > # time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat  127.0.0.1 =
9999
> > 10000+0 records in
> > 10000+0 records out
> > 10485760000 bytes (10 GB) copied, 50.2022 s, 209 MB/s
> >=20
> > real	0m50.210s
> > user	0m1.094s
> > sys	0m57.589s
>=20
> Thanks !
>=20
> Could you take a pef snapshot during the test ?
>=20
> # perf record -a -g sleep 10
> # perf report
>=20
>=20

On my laptop=20
Intel(R) Core(TM)2 Duo CPU     T8300  @ 2.40GHz
(2.6.35-22-generic #35-Ubuntu SMP Sat Oct 16 20:45:36 UTC 2010 x86_64
GNU/Linux) :

time dd if=3D/dev/zero bs=3D1M count=3D10000|netcat 127.0.0.1 9999
10000+0 enregistrements lus
10000+0 enregistrements =C3=A9crits
10485760000 octets (10 GB) copi=C3=A9s, 38,2691 s, 274 MB/s

real	0m38.274s
user	0m1.870s
sys	0m38.370s


perf top result :

-----------------------------------------------------------------------=
--------------------------
   PerfTop:    1948 irqs/sec  kernel:90.7%  exact:  0.0% [1000Hz cycles=
],  (all, 2 CPUs)
-----------------------------------------------------------------------=
--------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ________________=
___

             1867.00 12.4% copy_user_generic_string    [kernel.kallsyms=
] =20
             1166.00  7.7% __ticket_spin_lock          [kernel.kallsyms=
] =20
              744.00  4.9% __clear_user                [kernel.kallsyms=
] =20
              667.00  4.4% system_call                 [kernel.kallsyms=
] =20
              329.00  2.2% tcp_sendmsg                 [kernel.kallsyms=
] =20
              304.00  2.0% schedule                    [kernel.kallsyms=
] =20
              257.00  1.7% _raw_spin_unlock_irqrestore [kernel.kallsyms=
] =20
              231.00  1.5% fget_light                  [kernel.kallsyms=
] =20
              216.00  1.4% do_poll                     [kernel.kallsyms=
] =20
              203.00  1.3% __read_chk                  /lib/libc-2.12.1=
=2Eso
              202.00  1.3% __pollwait                  [kernel.kallsyms=
] =20
              201.00  1.3% __poll                      /lib/libc-2.12.1=
=2Eso
              187.00  1.2% system_call_after_swapgs    [kernel.kallsyms=
] =20
              176.00  1.2% __write                     /lib/libc-2.12.1=
=2Eso
              173.00  1.1% _raw_spin_lock_irqsave      [kernel.kallsyms=
] =20
              163.00  1.1% tcp_recvmsg                 [kernel.kallsyms=
] =20
              158.00  1.0% do_sys_poll                 [kernel.kallsyms=
] =20
              153.00  1.0% vfs_write                   [kernel.kallsyms=
] =20
              143.00  0.9% pipe_read                   [kernel.kallsyms=
] =20
              141.00  0.9% fput                        [kernel.kallsyms=
] =20
              121.00  0.8% common_file_perm            [kernel.kallsyms=
] =20
              120.00  0.8% _cond_resched               [kernel.kallsyms=
] =20


# vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----c=
pu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy=
 id wa
 2  0   1456 120056  51572 2606876    0    0   158    41  254  190  9  =
2 88  0
 2  0   1456 120140  51580 2606868    0    0    12     0  758 158309 11=
 76 13  0
 2  0   1456 119520  51588 2606896    0    0     0   176  778 160749  8=
 80 12  0
 2  0   1456 120388  51588 2606896    0    0     0     0  730 158201  9=
 76 16  0
 3  0   1456 120388  51588 2606896    0    0     0     0  745 158490  8=
 76 16  0
 2  0   1456 120520  51588 2606896    0    0     0     0  991 159120  9=
 78 13  0
 2  0   1456 120024  51588 2606896    0    0     0     0  653 160023 10=
 79 11  0
 3  0   1456 120520  51588 2606896    0    0     0     0  659 160614  8=
 78 14  0
 2  0   1456 120272  51596 2606896    0    0     0    80  695 159922 10=
 75 14  0
 4  0   1456 120272  51596 2606896    0    0     0     0  675 158010  7=
 79 14  0


# powertop
     PowerTOP version 1.13      (C) 2007 Intel Corporation

< Detailed C-state information is not P-states (frequencies)
                                      Turbo Mode    43.1%
                                        2.40 Ghz    48.0%
                                        2.00 Ghz     8.2%
                                        1.60 Ghz     0.7%
                                        1200 Mhz     0.1%

Wakeups-from-idle per second : 542.9    interval: 10.0s
no ACPI power usage estimate available

Top causes for wakeups:
  21.9% (196.5)   [kernel scheduler] Load balancing tick
  21.2% (190.7)   [Rescheduling interrupts] <kernel IPI>
  12.7% (114.0)   PS/2 keyboard/mouse/touchpad interrupt
  12.0% (107.9)   plugin-containe
  11.1% ( 99.3)   alsa-sink
   6.0% ( 53.8)   firefox-bin
   4.4% ( 39.7)   fping
   3.9% ( 35.2)   Xorg
   1.3% ( 11.3)   [b43] <interrupt>
   1.1% ( 10.0)   ksoftirqd/0
   0.4% (  4.0)D  nagios3
   0.2% (  1.9)D  gnome-terminal
   0.7% (  6.4)   [Thermal event interrupts] <kernel IPI>



