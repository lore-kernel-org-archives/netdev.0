From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Wed, 9 Dec 2015 08:01:10 -0800
Message-ID: <CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
	<20151208.120654.2127200076257822677.davem@davemloft.net>
	<56681B18.3030200@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35528 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbLIQBL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 11:01:11 -0500
Received: by ioc74 with SMTP id 74so63658923ioc.2
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 08:01:10 -0800 (PST)
In-Reply-To: <56681B18.3030200@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2015 at 4:14 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 08/12/15 17:06, David Miller wrote:
>> All of the headers get touched anyways as each layer of the stack > demuxes the packet. Therefore there is _ZERO_ cost to use 1's > complement to validate checksums in input. It's always superior.
>
> Ah, I understand now, it's touching the memory that's expensive, not adding
> up the numbers. Thanks for being patient with me :)
>
> So that just leaves the question of offloading multiple _TX_ checksums.
> Remote checksum offload would deal with this but the receiver might not
> support it, meaning that after decapsulation the packet will have a zero
> checksum (and still has chances to get corrupted); thus it's not necessarily
> safe to do unless you control both endpoints and know you have RCO
> everywhere.
> Convincing hardware designers to go the HW_CSUM way and only fill in the
> inner checksum, when their current approach can fill in both inner and outer
> checksums (though admittedly only for the protocols the hardware knows
> about), might be difficult.
>
But again, NETIF_F_IP[V6]_CSUM and NETIF_F_HW_CSUM describe
capabilities._not_ the interface. The interface currently allows only
one checksum to be offloaded at time, if we want to be able to offload
two checksums then the interface needs to be changed-- probably
something like defining a new capability like NETIF_F_HW_2CSUMS,
adding another csum_start,csum_offset pair into the sk_buff. The stack
will need to be modified also wherever CHECKSUM_PARTIAL is handled. If
your device is trying do offload more than one checksum on its own
accord without being asked to do so by the stack it is doing the wrong
thing!

> Remember that NICs are going to have packet parsing for those protocols
> anyway, because they need it for things like Windows-spec RSS, so in the
> hardware designer's mind, ossified offloads are "free".

> The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.

Please stop adding this disclaimer to your messages, it is not
appropriate for the list.

Tom
