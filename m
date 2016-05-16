From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v6 net-next 09/14] ip6_tun: Add infrastructure for doing encapsulation
Date: Mon, 16 May 2016 15:47:31 -0700
Message-ID: <CAKgT0UcMxXwRRi8QcrOFKpQ50OuLSEu90wM4wcVq5j=_=t54Eg@mail.gmail.com>
References: <1463434389-314297-1-git-send-email-tom@herbertland.com>
	<1463434389-314297-10-git-send-email-tom@herbertland.com>
	<CAKgT0UcKFEB6oPXtVQsQK0qSCRNRhxs4juvcMHh_1x8bRCPaXQ@mail.gmail.com>
	<CALx6S37-ca_k8qd_GwB3T0cHg75=_nF_79bgWi29b1UFgjbdig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34298 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbcEPWrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 18:47:32 -0400
Received: by mail-io0-f171.google.com with SMTP id 190so1837316iow.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 15:47:32 -0700 (PDT)
In-Reply-To: <CALx6S37-ca_k8qd_GwB3T0cHg75=_nF_79bgWi29b1UFgjbdig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 3:37 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, May 16, 2016 at 3:25 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Mon, May 16, 2016 at 2:33 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> Add encap_hlen and ip_tunnel_encap structure to ip6_tnl. Add functions
>>> for getting encap hlen, setting up encap on a tunnel, performing
>>> encapsulation operation.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>> ---
>>>  include/net/ip6_tunnel.h  | 58 ++++++++++++++++++++++++++++++++
>>>  net/ipv4/ip_tunnel_core.c |  5 +++
>>>  net/ipv6/ip6_tunnel.c     | 85 ++++++++++++++++++++++++++++++++++++++++++-----
>>>  3 files changed, 139 insertions(+), 9 deletions(-)
>>>
>>
>> So it looks like you completely dropped the two spots that were
>> updating mtu and max_headroom with the t->hlen.  I thought you needed
>> to at least have a check that used t->encap_hlen here in order to
>> avoid overflowing the buffer or exceeding skb_headroom, or am I
>> missing something?
>>
> Sorry, you're probably right. max_headroom seems to be an absolute
> value. mtu being calculated seems relative to what is in skbuff
> already.

The second invocation of max_headroom is an absolute value.  The first
one is used to measure if there is enough space for the headers we
will need to add.  My thought is that is why we need encap_hlen to be
added to the first case so we make sure there is enough room for the
UDP header if one is present plus the IPv6 header.

Also I just found another issue in this patch.  In ip6_tnl_dev_setup
you can probably just drop all references to "t" since you only assign
the pointer but you never actually access it.  I only noticed because
I was looking at adding support for TSO to the tunnel itself.

- Alex
