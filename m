From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 14 Jan 2008 13:25:22 -0600
Message-ID: <478BB722.1020004@nortel.com>
References: <478654C3.60806@nortel.com> <2c0942db0801112137k3f3f885ek212d5cbaecb7fea0@mail.gmail.com> <478B8473.6080506@nortel.com> <478B943C.7080009@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ray Lee <ray-lk@madrabbit.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:47190 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbYANT0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 14:26:14 -0500
In-Reply-To: <478B943C.7080009@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Chris Friesen a =C3=A9crit :

>> Based on profiling and instrumentation it seems like the cost of=20
>> sctp_endpoint_lookup_assoc() more than triples, which means that the=
=20
>> amount of time that bottom halves are disabled in that function also=
=20
>> triples.
>=20
> Any idea of the size of sctp hash size you have ?
> (your dmesg probably includes a message starting with SCTP: Hash tabl=
es=20
> configured...
> How many concurrent sctp sockets are handled ?

Our lab is currently rebooting, but I'll try and get this once it's bac=
k up.

> Maybe sctp_assoc_hashfn() is too weak for your use, and some chains a=
re=20
> *really* long.

Based on the profiling information we're spending time in=20
sctp_endpoint_lookup_assoc() which doesn't actually use hashes, so I=20
can't see how the hash would be related.  I'm pretty new to SCTP though=
,=20
so I may be missing something.

Here's the top results from readprofile, unfortunately these are=20
aggregated across both cpus so they don't really show what's going on.=20
The key thing is that sctp_endpoint_lookup_assoc() is the most expensiv=
e=20
kernel routine on this entire system.

   3147 .power4_idle                              22.4786
   1712 .native_idle                              20.3810
   1234 .sctp_endpoint_lookup_assoc                2.1725
   1212 ._spin_unlock_irqrestore                   6.4468
    778 .do_futex                                  0.3791
    447 ._spin_unlock_irq                          4.2981
    313 .fget                                      1.7784
    277 .fput                                      3.8472
    275 .kfree                                     0.7473
    234 .__kmalloc                                 0.5571
    131 SystemCall_common                          0.3411
    130 .sctp_assoc_is_match                       0.6373
    123 .lock_sock                                 0.4155
    119 .find_vma                                  0.6919
    116 .kmem_cache_alloc                          0.3580
    111 .kmem_cache_free                           0.3343
    106 .skb_release_data                          0.4907
    102 .__copy_tofrom_user                        0.0724
    100 .exit_elf_binfmt                           1.9231
    100 .do_select                                 0.0820


Chris
