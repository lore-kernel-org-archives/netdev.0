From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 08:56:47 +0200
Message-ID: <1271401007.16881.3762.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:45983 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086Ab0DPG45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 02:56:57 -0400
Received: by bwz25 with SMTP id 25so2589187bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 23:56:55 -0700 (PDT)
In-Reply-To: <20100415.233334.242114544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 23:33 -0700, David Miller a =C3=A9crit :
> From: Tom Herbert <therbert@google.com>
> Date: Thu, 15 Apr 2010 22:47:08 -0700 (PDT)
>=20
> > Version 5 of RFS:
> > - Moved rps_sock_flow_sysctl into net/core/sysctl_net_core.c as a
> > static function.
> > - Apply limits to rps_sock_flow_entires systcl and rps_flow_count
> > sysfs variable.
>=20
> I've read this over a few times and I think it's ready to go into
> net-next-2.6, we can tweak things as-needed from here on out.
>=20
> Eric, what do you think?

I read the patch and found no error.

I booted a test machine and performed some tests

I am a bit worried of a tbench regression I am looking at right now.

if RFS disabled , tbench 16   ->  4408.63 MB/sec=20


# grep . /sys/class/net/lo/queues/rx-0/*
/sys/class/net/lo/queues/rx-0/rps_cpus:00000000
/sys/class/net/lo/queues/rx-0/rps_flow_cnt:8192
# cat /proc/sys/net/core/rps_sock_flow_entries
8192


echo ffff >/sys/class/net/lo/queues/rx-0/rps_cpus

tbench 16 -> 2336.32 MB/sec


-----------------------------------------------------------------------=
-----------------------------------------------------------------------=
-------
   PerfTop:   14561 irqs/sec  kernel:86.3% [1000Hz cycles],  (all, 16 C=
PUs)
-----------------------------------------------------------------------=
-----------------------------------------------------------------------=
-------

             samples  pcnt function                       DSO
             _______ _____ ______________________________ _____________=
_____________________________________________

             2664.00  5.1% copy_user_generic_string       /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
             2323.00  4.4% acpi_os_read_port              /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
             1641.00  3.1% _raw_spin_lock_irqsave         /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
             1260.00  2.4% schedule                       /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
             1159.00  2.2% _raw_spin_lock                 /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
             1051.00  2.0% tcp_ack                        /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              991.00  1.9% tcp_sendmsg                    /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              922.00  1.8% tcp_recvmsg                    /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              821.00  1.6% child_run                      /usr/bin/tben=
ch                                          =20
              766.00  1.5% all_string_sub                 /usr/bin/tben=
ch                                          =20
              630.00  1.2% __switch_to                    /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              608.00  1.2% __GI_strchr                    /lib/tls/libc=
-2.3.4.so                                   =20
              606.00  1.2% ipt_do_table                   /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              600.00  1.1% __GI_strstr                    /lib/tls/libc=
-2.3.4.so                                   =20
              556.00  1.1% __netif_receive_skb            /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              504.00  1.0% tcp_transmit_skb               /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              502.00  1.0% tick_nohz_stop_sched_tick      /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              481.00  0.9% _raw_spin_unlock_irqrestore    /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              473.00  0.9% next_token                     /usr/bin/tben=
ch                                          =20
              449.00  0.9% ip_rcv                         /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              423.00  0.8% call_function_single_interrupt /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              422.00  0.8% ia32_sysenter_target           /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              420.00  0.8% compat_sys_socketcall          /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              401.00  0.8% mod_timer                      /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              400.00  0.8% process_backlog                /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              399.00  0.8% ip_queue_xmit                  /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              387.00  0.7% select_task_rq_fair            /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              377.00  0.7% _raw_spin_lock_bh              /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux
              360.00  0.7% tcp_v4_rcv                     /lib/modules/=
2.6.34-rc3-03375-ga4fbf84-dirty/build/vmlinux

But if RFS is on, why activating rps_cpus change tbench ?



