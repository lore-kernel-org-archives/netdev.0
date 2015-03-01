From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v2 4/7] net: packet: use skb->dev as storage for
 skb orig len instead of skb->cb[]
Date: Sun, 1 Mar 2015 07:09:54 +0200
Message-ID: <CAHsH6Gv8Dh3RQ0V7KURcca9bzZGY0FwiqGj-mP9oKA_Vv72nUA@mail.gmail.com>
References: <CAHsH6Guq33N755dcuNEmzgP06O=PBdy2Tzt5vSr-iRFoj4uGtw@mail.gmail.com>
	<20150228.150830.1726900309943339124.davem@davemloft.net>
	<CAHsH6GvvQxHbt4JJrotn3y=BG172Wbw4NrMD+gTUA_R=jbPDTw@mail.gmail.com>
	<20150228.160047.214686672558902639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	linux-bluetooth@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:36653 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbbCAFJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 00:09:57 -0500
In-Reply-To: <20150228.160047.214686672558902639.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 28, 2015 at 11:00 PM, David Miller <davem@davemloft.net> wrote:
> From: Eyal Birger <eyal.birger@gmail.com>
> Date: Sat, 28 Feb 2015 22:38:04 +0200
>
>> My concern is that any value I pick based on the existing implementations
>> would need to be adjusted come a protocol with a larger address length.
>
> Then we need a method that requires protocols to register their
> address length in a manner that will allow us to validate that
> limit at compile time.
>

Sorry to reiterate this, but such validation will inherently become the
actual limit for hardware addresses.
So, it would be equivalent to changing the in-kernel definition of
MAX_ADDR_SIZE.

Is this something to be considered?

> This is not rocket science.
>
> Right now we're proposing to do utterly stupid shit like encoding
> integers in device pointers in the sk_buff, when that is absolutely
> not necessary at all.

Ok. Another suggestion I received was to delay the preparation of the full
sockaddr_ll until it is needed, and store the skb original length in the first
two fields (sll_protocol and sll_family) as they can be derived later on from
the skb.

IMHO, It would still be somewhat of a hack though.

Would that approach be considered?

Regards,
Eyal.
