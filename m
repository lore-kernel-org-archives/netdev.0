From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 09:18:03 +0200
Message-ID: <1271402283.16881.3791.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:34840 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970Ab0DPHSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 03:18:14 -0400
Received: by bwz25 with SMTP id 25so2609213bwz.28
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 00:18:12 -0700 (PDT)
In-Reply-To: <1271401007.16881.3762.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 avril 2010 =C3=A0 08:56 +0200, Eric Dumazet a =C3=A9crit=
 :

> I read the patch and found no error.
>=20
> I booted a test machine and performed some tests
>=20
> I am a bit worried of a tbench regression I am looking at right now.
>=20
> if RFS disabled , tbench 16   ->  4408.63 MB/sec=20
>=20
>=20
> # grep . /sys/class/net/lo/queues/rx-0/*
> /sys/class/net/lo/queues/rx-0/rps_cpus:00000000
> /sys/class/net/lo/queues/rx-0/rps_flow_cnt:8192
> # cat /proc/sys/net/core/rps_sock_flow_entries
> 8192
>=20
>=20
> echo ffff >/sys/class/net/lo/queues/rx-0/rps_cpus
>=20
> tbench 16 -> 2336.32 MB/sec
>=20
>=20
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
---------
>    PerfTop:   14561 irqs/sec  kernel:86.3% [1000Hz cycles],  (all, 16=
 CPUs)
> ---------------------------------------------------------------------=
-----------------------------------------------------------------------=
---------
>=20
>              samples  pcnt function                       DSO
>              _______ _____ ______________________________ ___________=
_______________________________________________
>=20
>              2664.00  5.1% copy_user_generic_string       /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>              2323.00  4.4% acpi_os_read_port              /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>              1641.00  3.1% _raw_spin_lock_irqsave         /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>              1260.00  2.4% schedule                       /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>              1159.00  2.2% _raw_spin_lock                 /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>              1051.00  2.0% tcp_ack                        /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               991.00  1.9% tcp_sendmsg                    /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               922.00  1.8% tcp_recvmsg                    /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               821.00  1.6% child_run                      /usr/bin/tb=
ench                                          =20
>               766.00  1.5% all_string_sub                 /usr/bin/tb=
ench                                          =20
>               630.00  1.2% __switch_to                    /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               608.00  1.2% __GI_strchr                    /lib/tls/li=
bc-2.3.4.so                                   =20
>               606.00  1.2% ipt_do_table                   /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               600.00  1.1% __GI_strstr                    /lib/tls/li=
bc-2.3.4.so                                   =20
>               556.00  1.1% __netif_receive_skb            /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               504.00  1.0% tcp_transmit_skb               /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               502.00  1.0% tick_nohz_stop_sched_tick      /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               481.00  0.9% _raw_spin_unlock_irqrestore    /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               473.00  0.9% next_token                     /usr/bin/tb=
ench                                          =20
>               449.00  0.9% ip_rcv                         /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               423.00  0.8% call_function_single_interrupt /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               422.00  0.8% ia32_sysenter_target           /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               420.00  0.8% compat_sys_socketcall          /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               401.00  0.8% mod_timer                      /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               400.00  0.8% process_backlog                /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               399.00  0.8% ip_queue_xmit                  /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               387.00  0.7% select_task_rq_fair            /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               377.00  0.7% _raw_spin_lock_bh              /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>               360.00  0.7% tcp_v4_rcv                     /lib/module=
s/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
>=20
> But if RFS is on, why activating rps_cpus change tbench ?
>=20

Hmm, I wonder if its not an artifact of net-next-2.6 being a bit old
(versus linux-2.6). I know scheduler guys did some tweaks.

Because apparently, some cpus are idle part of their time (30% ???)

Or a new bug on cpu accounting, reporting idle time while cpus are
busy....

# vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----c=
pu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy=
 id wa
16  0      0 5670264  13280  63392    0    0     2     1 1512  227 12 4=
7 41  0
18  0      0 5669396  13280  63392    0    0     0     0 657952 1606102=
 14 58 28  0
17  0      0 5668776  13288  63392    0    0     0    12 656701 1606369=
 14 58 28  0
18  0      0 5669644  13288  63392    0    0     0     0 657636 1603960=
 15 57 28  0
17  0      0 5670900  13288  63392    0    0     0     0 666425 1584847=
 15 56 29  0
15  0      0 5669164  13288  63392    0    0     0     0 682578 1472616=
 14 56 30  0
16  0      0 5669412  13288  63392    0    0     0     0 695767 1506302=
 14 54 32  0
14  0      0 5668916  13296  63396    0    0     4   148 685286 1482897=
 14 56 30  0
17  0      0 5669784  13296  63396    0    0     0     0 683910 1477994=
 14 56 30  0
18  0      0 5670032  13296  63396    0    0     0     0 692023 1497195=
 14 55 31  0
16  0      0 5669040  13296  63396    0    0     0     0 677477 1468157=
 14 56 30  0
16  0      0 5668916  13312  63396    0    0     0    32 489358 1048553=
 14 57 30  0
18  0      0 5667924  13320  63396    0    0     0    12 424787 897145 =
15 55 29  0

RFS off :

# vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----c=
pu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy=
 id wa
24  0      0 5669624  13632  63476    0    0     2     1  261   82 12 4=
8 40  0
26  0      0 5669492  13632  63476    0    0     0     0 4223 1740651 2=
1 71  7  0
23  0      0 5669864  13640  63476    0    0     0    12 4205 1731882 2=
1 71  8  0
23  0      0 5670484  13640  63476    0    0     0     0 4176 1733448 2=
1 71  8  0
24  0      0 5670588  13640  63476    0    0     0     0 4176 1733845 2=
1 72  7  0
21  0      0 5671084  13640  63476    0    0     0     0 4200 1734990 2=
0 73  7  0
23  0      0 5671580  13640  63476    0    0     0     0 4168 1735100 2=
1 71  8  0
23  0      0 5671704  13640  63480    0    0     4   132 4221 1733428 2=
1 72  7  0
22  0      0 5671952  13640  63480    0    0     0     0 4190 1730370 2=
1 72  8  0
20  0      0 5672292  13640  63480    0    0     0     0 4212 1732084 2=
2 70  8  0



