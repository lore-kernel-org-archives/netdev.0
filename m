From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 2/3] net: UDP gro_receive accept csum=0
Date: Fri, 14 Feb 2014 00:50:49 +0200
Message-ID: <CAJZOPZKRiR-XZo1b9-TQG9ULpVhL31bTBD+4Z7T+ODZcPX_L2g@mail.gmail.com>
References: <alpine.DEB.2.02.1402110928070.7090@tomh.mtv.corp.google.com>
	<52FC7D0C.1020601@mellanox.com>
	<CA+mtBx_+fc5YdQE+M49QD5ymuD7bfDdedfi2AuCDhU2=CawN6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Tom Herbert <therbert@google.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:61091 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbaBMWuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:50:50 -0500
Received: by mail-pd0-f171.google.com with SMTP id g10so11091787pdj.30
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 14:50:50 -0800 (PST)
In-Reply-To: <CA+mtBx_+fc5YdQE+M49QD5ymuD7bfDdedfi2AuCDhU2=CawN6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 12:27 AM, Tom Herbert <therbert@google.com> wrote:

>> [...] this is according to the conventions set by
>> 0afb166 vxlan: Add capability of Rx checksum offload for inner packet
>> 6a674e9 net: Add support for hardware-offloaded encapsulation
>> B/c after finalizing the GRO work and decapsulating, skb injected up into
>> the TCP stack with ip_summed equals to CHECKSUM_NONE are rejected. If >> this assumption is wrong, maybe we can remove testing the ip_summed field
>> here altogether?

> If I'm interpreting the semantics correctly, when skb->encapsulation
> is set the ip_summed is valid for both the inner and outer header
> (e.g. CHECKSUM_COMPLETE is always assumed okay for both layers). If
> skb->encapsulation is not set then ip_summed is only valid for outer header.

Yep, I think this would be correct interpertation, Joseph, agree?

> So then the patch is broken in the case that encap is not set,
> ip_summed is CHECKSUM_UNNECESSARY, csum == 0, and we need to
> validate the inner checksum.

Just to make sure, by "the patch" you refer to your patch or the current code?

> But even worse, is there a fundamental issue where udp4_csum_init is able
> to change ip_summed to be CHECKSUM_UNNECESSARY (either check == 0
> or ip_summed == CHECKSUM_UNNECESSARY) regardless of
> skb->encapsulation, sending the packet into encap_rcv which could
> ultimately incorrectly apply ip_summed on the inner TCP/UDP packet?

By fundamental you mean performance issue or functionality issue (bug) or both?
