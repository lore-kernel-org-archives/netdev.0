From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 05:03:35 +0100
Message-ID: <1291176215.2856.383.camel@edumazet-laptop>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
	 <1291109699.2904.11.camel@edumazet-laptop>
	 <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
	 <1291127670.2904.96.camel@edumazet-laptop>
	 <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rui <wirelesser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43947 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192Ab0LAEDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 23:03:40 -0500
Received: by wyb28 with SMTP id 28so6486754wyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 20:03:39 -0800 (PST)
In-Reply-To: <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 11:48 +0800, Rui a =C3=A9crit =
:

> if  RPS can spread the load into 4 separate cpus, how about the
> "packet_rcv(or tpacket_rcv)" ? will they run in parallel?
>=20
> as I use 'tcpdump(PACKET_MMAP)' to copy the packet to user space, I
> expect there are simultaneous packet_rcv running in each CPU to put
> the packet into ringbuffer.

Yes, the filter code wan run in parallel with no particular slowdown,
since code and bpf data is shared by all cpus (no writes)

But its rather important for performance that each cpu store packets
into its own packet socket or ring buffer, to avoid false sharing
slowdowns.

With such a setup (split packets to four cpus, then make sure one cpu
deliver packets to one particular PACKET socket/ring buffer), it should
really be fast enough.



