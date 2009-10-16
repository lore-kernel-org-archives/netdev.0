From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/4 v2] net: Use sk_tx_queue_mapping for connected sockets
Date: Fri, 16 Oct 2009 18:26:56 +0530
Message-ID: <OFAE5CC975.C26B600E-ON65257651.00401683-65257651.004721BC@in.ibm.com>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain> <20091016072132.24384.38301.sendpatchset@localhost.localdomain> <4AD84188.7030804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([59.145.155.3]:52516 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbZJPM6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 08:58:10 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9GCvM3N021606
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:27:22 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9GCvMKn2564334
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:27:22 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9GCvL7s000410
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:27:22 +0530
In-Reply-To: <4AD84188.7030804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 10/16/2009 03:18:56 PM:

> Are we sure that for selection done by skb_tx_hash(dev, skb),
> rx packets will use the same queue/cpu ?
>
> Probably not, since it uses sk->sk_hash (tcp/udp port) :

Yes, I expect the same.

> If NIC has some proprietary hash, and selects rx queue 3 for feeding us
> packets, it would be nice to also use tx queue 3 for transmit.

I had written: "This is not saved if either skb rx was recorded, or
...". It is somewhat misleading, and I will try to correct it. The
idea is that if the same incoming skb is used for response after the
connection is setup, which I think is not possible in this case, then
txq will be same as rxq. See more below...

> We would have to record in sk the rx queue chosen by the device
> when processing SYN / SYN-ACK packet for example for tcp flows.

I wait for tcp_v4_syn_recv_sock to finish and create a connection.
sk_setup_caps/__sk_dst_set are called for the new socket resulting
in sk_dst_cache getting set (I cannot set the cache till the
connection is finished and dst is set). I guess that means that I
will wait for another skb to come and the response will use skb_tx_hash
instead of using the rx recorded.

Will this suffice, but if not, is it something I should handle or an
add-on patch should do instead?

Thanks,

- KK

