From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 09 Nov 2010 07:38:35 +0100
Message-ID: <1289284715.2790.87.camel@edumazet-laptop>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <AANLkTi=HhouZymj0R7JsDy-X1LDbfT_WL0x10EMhdOho@mail.gmail.com>
	 <1289280152.2790.23.camel@edumazet-laptop>
	 <1289283797.2790.84.camel@edumazet-laptop>
	 <AANLkTikAPaU_2=wS_T3V-8xFZm-G3qutJBxY8yb0QCYL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50588 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703Ab0KIGiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 01:38:46 -0500
Received: by wwi18 with SMTP id 18so450892wwi.1
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 22:38:45 -0800 (PST)
In-Reply-To: <AANLkTikAPaU_2=wS_T3V-8xFZm-G3qutJBxY8yb0QCYL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 17:30 +1100, Andrew Hendry a =C3=A9cri=
t :
> most my slowdown was kmemleak left on.
>=20
> After fixing its is still a lot slower than your dev system
> .
> # time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat  127.0.0.1 99=
99
> 10000+0 records in
> 10000+0 records out
> 10485760000 bytes (10 GB) copied, 25.8182 s, 406 MB/s
>=20
> real	0m25.821s
> user	0m1.502s
> sys	0m33.463s
>=20
> ---------------------------------------------------------------------=
---------------------------------------------
>    PerfTop:     241 irqs/sec  kernel:56.8%  exact:  0.0% [1000Hz
> cycles],  (all, 8 CPUs)
> ---------------------------------------------------------------------=
---------------------------------------------
>=20
>              samples  pcnt function                    DSO
>              _______ _____ ___________________________
> ______________________________________
>=20
>              1255.00  8.7% hpet_msi_next_event
> /lib/modules/2.6.37-rc1+/build/vmlinux
>              1081.00  7.5% copy_user_generic_string
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               863.00  6.0% __ticket_spin_lock
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               498.00  3.5% do_sys_poll
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               455.00  3.2% system_call
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               409.00  2.8% fget_light
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               348.00  2.4% tcp_sendmsg
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               269.00  1.9% fsnotify
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               258.00  1.8% _raw_spin_unlock_irqrestore
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               223.00  1.6% _raw_spin_lock_irqsave
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               203.00  1.4% __clear_user
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               184.00  1.3% tcp_poll
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               178.00  1.2% vfs_write
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               165.00  1.1% tcp_recvmsg
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               152.00  1.1% pipe_read
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               149.00  1.0% schedule
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               135.00  0.9% rw_verify_area
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               135.00  0.9% __pollwait
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               130.00  0.9% __write
> /lib/libc-2.12.1.so
>               127.00  0.9% __ticket_spin_unlock
> /lib/modules/2.6.37-rc1+/build/vmlinux
>               126.00  0.9% __poll
> /lib/libc-2.12.1.so
>=20
>=20


Hmm, your clock source is HPET, that might explain the problem on a
scheduler intensive workload.

My HP dev machine
# grep . /sys/devices/system/clocksource/clocksource0/*
/sys/devices/system/clocksource/clocksource0/available_clocksource:tsc =
hpet acpi_pm=20
/sys/devices/system/clocksource/clocksource0/current_clocksource:tsc

My laptop:
$ grep . /sys/devices/system/clocksource/clocksource0/*
/sys/devices/system/clocksource/clocksource0/available_clocksource:tsc =
hpet acpi_pm=20
/sys/devices/system/clocksource/clocksource0/current_clocksource:tsc


