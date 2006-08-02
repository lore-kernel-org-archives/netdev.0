From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Wed, 02 Aug 2006 22:03:16 +0900
Message-ID: <44D0A294.5000208@linux-ipv6.org>
References: <44CB2914.9010803@linux-ipv6.org> <20060729141244.GJ8334@innerghost.net> <44D01AEE.3030606@linux-ipv6.org> <20060802104756.GN8334@innerghost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:32402 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1750911AbWHBNDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 09:03:21 -0400
To: Hugo Santos <hsantos@av.it.pt>
In-Reply-To: <20060802104756.GN8334@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hugo Santos wrote:
>    Although the ICMP-filter approach would be better, it is not flexible
>  enough to handle this situation. We must also send ICMPv6 Parameter
>  Problems when ip6mh_proto isn't IPPROTO_NONE. I don't think it is too

I don't think IPPROTO_NONE case is a suitable example here
(it is also supported by our kernel patch).
We don't have any problem about who checks next header field since its
offset of mobility header never changes then its value
can be checked as the same way for all type number.

But anyway,

>  much of a burthen to handle ICMPv6 in the control daemon because you
>  should already do so to react to ICMPv6 error messages from peers
>  concerning MIPv6 signalling. I'm strongly against doing these checks in
>  the kernel for the simple reason that it is not easily extendable.  You
>  wouldn't be able to deploy a new daemon version over an existing kernel
>  with these changes if it supported a new control protocol with new
>  messages. I think we should follow a different path here and i propose
>  either have a hdrinc=1 mode (for reception only) for protocol raw
>  sockets, possibly adding with control on reception which specifies the
>  offset of the UPL header; or have a control message to obtain the
>  network headers. For instance:
>
>       put_cmsg(msg, SOL_IPV6, ..., (skb->h.raw - skb->nh.raw),
>                skb->nh.raw);

I can agree such suggestion as new kernel feature but I'm not sure
MIPv6 stuff should depend on it just for new message type to extend later.
On our design MIPv6 signaling itself is almost done by user-space daemon.
When developer wants to add new or original type number, it is enough for
kernel to be added the number and its length. All other things can be modified at
user-space application. If there is much requirement to add new type number
without any modification of kernel code at all I would support ICMPv6 filter approach,
too.

-- 
Masahide NAKAMURA
