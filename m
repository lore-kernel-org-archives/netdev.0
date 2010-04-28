From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Wed, 28 Apr 2010 16:34:03 +0200
Message-ID: <1272465243.2267.76.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop>
	 <1272464368.2267.72.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:45521 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570Ab0D1OeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 10:34:11 -0400
Received: by bwz19 with SMTP id 19so12685bwz.21
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 07:34:08 -0700 (PDT)
In-Reply-To: <1272464368.2267.72.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 avril 2010 =C3=A0 16:19 +0200, Eric Dumazet a =C3=A9crit=
 :

> I forgot to say that with my previous DDOS test/bench (16 cpus trying=
 to
> feed one udp socket), my receiver can now process 420.000 pps instead=
 of
> 200.000 ;)

And perf top of the cpu dedicated to the thread doing the recvmsg() is =
:
(after patch)

-----------------------------------------------------------------------=
-----------------------------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:98.0% [1000Hz cycles],  (all, cpu:=
 1)
-----------------------------------------------------------------------=
-----------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ______________=
______________

             5463.00 45.5% _raw_spin_lock_bh             vmlinux       =
             =20
              761.00  6.3% copy_user_generic_string      vmlinux       =
             =20
              662.00  5.5% sock_recv_ts_and_drops        vmlinux       =
             =20
              645.00  5.4% kfree                         vmlinux       =
             =20
              568.00  4.7% _raw_spin_lock                vmlinux       =
             =20
              494.00  4.1% __skb_recv_datagram           vmlinux       =
             =20
              488.00  4.1% skb_copy_datagram_iovec       vmlinux       =
             =20
              467.00  3.9% __slab_free                   vmlinux       =
             =20
              176.00  1.5% udp_recvmsg                   vmlinux       =
             =20
              168.00  1.4% ia32_sysenter_target          vmlinux       =
             =20
              161.00  1.3% kmem_cache_free               vmlinux       =
             =20
              161.00  1.3% _raw_spin_lock_irqsave        vmlinux       =
             =20
              151.00  1.3% memcpy_toiovec                vmlinux       =
             =20
              131.00  1.1% fget_light                    vmlinux       =
             =20
              130.00  1.1% sock_rfree                    vmlinux       =
             =20
              104.00  0.9% inet_recvmsg                  vmlinux       =
             =20
               99.00  0.8% dst_release                   vmlinux       =
             =20
               98.00  0.8% skb_release_head_state        vmlinux       =
             =20
               83.00  0.7% __sk_mem_reclaim              vmlinux       =
             =20
               75.00  0.6% sys_recvfrom                  vmlinux       =
             =20
               61.00  0.5% sysexit_from_sys_call         vmlinux       =
             =20
               59.00  0.5% fput                          vmlinux       =
             =20
               56.00  0.5% schedule                      vmlinux       =
             =20
               56.00  0.5% sock_recvmsg                  vmlinux       =
             =20
               54.00  0.4% move_addr_to_user             vmlinux       =
             =20
               51.00  0.4% compat_sys_socketcall         vmlinux       =
             =20
               48.00  0.4% _raw_spin_unlock_bh           vmlinux       =
            =20


