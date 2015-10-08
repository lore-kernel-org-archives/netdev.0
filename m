From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC 3/3] mlx4: Call skb_csum_offload_check to check offloadability
Date: Fri, 9 Oct 2015 00:39:30 +0300
Message-ID: <CAJ3xEMgNGToK++17mgqnwQFJ4L3KxwYuz45d59GKtSos73YqbA@mail.gmail.com>
References: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
	<1444088364-2839440-4-git-send-email-tom@herbertland.com>
	<56153D46.2080606@mellanox.com>
	<CALx6S37HUhTbYQEv4Q0aXN9Z-oqNUmsZDx495Ckst7PdF2gk2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	David Woodhouse <dwmw2@infradead.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34912 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbbJHVjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 17:39:31 -0400
Received: by ioiz6 with SMTP id z6so72804911ioi.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 14:39:30 -0700 (PDT)
In-Reply-To: <CALx6S37HUhTbYQEv4Q0aXN9Z-oqNUmsZDx495Ckst7PdF2gk2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 9:07 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Wed, Oct 7, 2015 at 8:41 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> On 10/6/2015 2:39 AM, Tom Herbert wrote:

>>>   +static const struct skb_csum_offl_spec csum_offl_spec = {
>>> +       .ipv4_okay = 1,
>>> +       .ipv6_okay = 1,
>>> +       .encap_okay = 1,
>>> +       .tcp_okay = 1,
>>> +       .udp_okay = 1,
>>> +};
>>> +
[...]


> Or, I would only give the mlnx support as an example. I think driver
> owners would need to implement the specification for the their devices.

sure, sorry to bother on that.

>> Another constraint, is that when the device does support (say) TCP TX
>> checksum offload for the inner packet they don't support UDP
>> checksum offload for the outer packet.

> We can add such things to the specification. One value I see in having
> a common structure to describe the checksum capabilities is that
> becomes a way to clearly document what is (and is not) supported by
> devices.

> btw, I don't quite understand your example. If a device does not
> support UDP checksum there is a flag for that in the specification.

But we do support UDP checksum generation for not-tunneled packets, so
the specification should somehow capture this combination.

> If the stack sends a TCP packet encapsulated in a UDP packet with UDP
> checksum enabled, it will try to offload the UDP checksum and not the
> TCP one.

Not following... who is "it" in this sentence, the stack or the device?

We don't advertise NETIF_F_GSO_UDP_TUNNEL_CSUM so for UDP tunning
GSO-ed packets  we should be fine. For non GSO... you say this works
only b/c the default for the vxlan driver is to use zero udp checksum?

> There is currently no interface to offload two checksums in
> the same packet (in non-GRO at least)

GRO? aren't we talking on xmit?

> and with things like RCO we probably will never need that anyway.
