From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net v3 3/5] packet: only allow extra vlan len on ethernet
 devices
Date: Thu, 12 Nov 2015 00:07:42 +0100
Message-ID: <5643CA3E.50703@iogearbox.net>
References: <cover.1447278504.git.daniel@iogearbox.net> <45cbb079a6f1c88aff9da37198c8f8bb0414aefd.1447278504.git.daniel@iogearbox.net> <CA+FuTSeg9tyi+yd+2LuuzPcHs=H4NkPQXqEb+yrR9tQOKqim3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59417 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbbKKXHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 18:07:51 -0500
In-Reply-To: <CA+FuTSeg9tyi+yd+2LuuzPcHs=H4NkPQXqEb+yrR9tQOKqim3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2015 11:55 PM, Willem de Bruijn wrote:
> On Wed, Nov 11, 2015 at 5:25 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
...
>> +       if (!gso_type && (len > dev->mtu + reserve + extra_len) &&
>> +           !packet_extra_vlan_len_allowed(dev, skb)) {
>> +               err = -EMSGSIZE;
>> +               goto out_free;
>
> This nicely reuses the same code in three locations.
>
> If you end up having to send a v4, it would be nice to also fold the
> repeated len check into the shared code. Variable reserve here is
> just dev->hard_header_len. No need to spin a patch just for that
> cleanup, though.

Noted, I was also thinking for net-next to move the tpacket_snd() check
into tpacket_fill_skb(), that would save us to do the likely(tp_len >= 0)
check there. Can take care of both when net-next opens, I feared there
would be critics that it's not ending up minimal enough otherwise. ;)

Thanks,
Daniel
