From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 20:15:58 +0200
Message-ID: <1271441758.16881.4207.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
	 <w2t65634d661004160835z4a604ee7pb5f9d395fe61b5db@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:48901 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757722Ab0DPSQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 14:16:04 -0400
Received: by bwz25 with SMTP id 25so3464608bwz.28
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 11:16:02 -0700 (PDT)
In-Reply-To: <w2t65634d661004160835z4a604ee7pb5f9d395fe61b5db@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 avril 2010 =C3=A0 08:35 -0700, Tom Herbert a =C3=A9crit =
:
> Eric, thanks for testing that.  Admittedly, we have looked at enablin=
g
> RFS/RPS over loopback.   I'll look at that today also.
>=20
>=20

Hi Tom

I am sorry, but I could not work on this today. I hope I can find some
time a bit later.



> On Thu, Apr 15, 2010 at 11:56 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > Le jeudi 15 avril 2010 =C3=A0 23:33 -0700, David Miller a =C3=A9cri=
t :
> >> From: Tom Herbert <therbert@google.com>
> >> Date: Thu, 15 Apr 2010 22:47:08 -0700 (PDT)
> >>
> >> > Version 5 of RFS:
> >> > - Moved rps_sock_flow_sysctl into net/core/sysctl_net_core.c as =
a
> >> > static function.
> >> > - Apply limits to rps_sock_flow_entires systcl and rps_flow_coun=
t
> >> > sysfs variable.
> >>
> >> I've read this over a few times and I think it's ready to go into
> >> net-next-2.6, we can tweak things as-needed from here on out.
> >>
> >> Eric, what do you think?
> >
> > I read the patch and found no error.
> >
> > I booted a test machine and performed some tests
> >
> > I am a bit worried of a tbench regression I am looking at right now=
=2E
> >
> > if RFS disabled , tbench 16   ->  4408.63 MB/sec
> >
> >
> > # grep . /sys/class/net/lo/queues/rx-0/*
> > /sys/class/net/lo/queues/rx-0/rps_cpus:00000000
> > /sys/class/net/lo/queues/rx-0/rps_flow_cnt:8192
> > # cat /proc/sys/net/core/rps_sock_flow_entries
> > 8192
> >
> >
> > echo ffff >/sys/class/net/lo/queues/rx-0/rps_cpus
> >
> > tbench 16 -> 2336.32 MB/sec
> >
> >
> > -------------------------------------------------------------------=
-----------------------------------------------------------------------=
-----------
> >   PerfTop:   14561 irqs/sec  kernel:86.3% [1000Hz cycles],  (all, 1=
6 CPUs)
> > -------------------------------------------------------------------=
-----------------------------------------------------------------------=
-----------
> >
> >             samples  pcnt function                       DSO
> >             _______ _____ ______________________________ __________=
________________________________________________
> >
> >             2664.00  5.1% copy_user_generic_string       /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >             2323.00  4.4% acpi_os_read_port              /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >             1641.00  3.1% _raw_spin_lock_irqsave         /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >             1260.00  2.4% schedule                       /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >             1159.00  2.2% _raw_spin_lock                 /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >             1051.00  2.0% tcp_ack                        /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              991.00  1.9% tcp_sendmsg                    /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              922.00  1.8% tcp_recvmsg                    /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              821.00  1.6% child_run                      /usr/bin/t=
bench
> >              766.00  1.5% all_string_sub                 /usr/bin/t=
bench
> >              630.00  1.2% __switch_to                    /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              608.00  1.2% __GI_strchr                    /lib/tls/l=
ibc-2.3.4.so
> >              606.00  1.2% ipt_do_table                   /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              600.00  1.1% __GI_strstr                    /lib/tls/l=
ibc-2.3.4.so
> >              556.00  1.1% __netif_receive_skb            /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              504.00  1.0% tcp_transmit_skb               /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              502.00  1.0% tick_nohz_stop_sched_tick      /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              481.00  0.9% _raw_spin_unlock_irqrestore    /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              473.00  0.9% next_token                     /usr/bin/t=
bench
> >              449.00  0.9% ip_rcv                         /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              423.00  0.8% call_function_single_interrupt /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              422.00  0.8% ia32_sysenter_target           /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              420.00  0.8% compat_sys_socketcall          /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              401.00  0.8% mod_timer                      /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              400.00  0.8% process_backlog                /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              399.00  0.8% ip_queue_xmit                  /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              387.00  0.7% select_task_rq_fair            /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              377.00  0.7% _raw_spin_lock_bh              /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >              360.00  0.7% tcp_v4_rcv                     /lib/modul=
es/2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
> >
> > But if RFS is on, why activating rps_cpus change tbench ?
> >
> >
> >
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


