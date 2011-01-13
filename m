From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH net-next-2.6] etherdevice.h: Add is_unicast_ether_addr
 function
Date: Thu, 13 Jan 2011 11:38:42 -0500
Message-ID: <4D2F2A92.7020909@tilera.com>
References: <20110112.234250.10542369.davem@davemloft.net>	 <1294906496-14950-1-git-send-email-tklauser@distanz.ch>	 <1294907081.4114.35.camel@Joe-Laptop> <1294908916.3570.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([206.83.70.70]:25598 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757019Ab1AMQin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 11:38:43 -0500
In-Reply-To: <1294908916.3570.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/2011 3:55 AM, Eric Dumazet wrote:
> Le jeudi 13 janvier 2011 =C3=A0 00:24 -0800, Joe Perches a =C3=A9crit=
 :
>> On Thu, 2011-01-13 at 09:14 +0100, Tobias Klauser wrote:
>>> >From a check for !is_multicast_ether_addr it is not always obvious=
 that
>>> we're checking for a unicast address. So add this helper function t=
o
>>> make those code paths easier to read.
>>>  include/linux/etherdevice.h |   11 +++++++++++
>> []
>>>  /**
>>> + * is_unicast_ether_addr - Determine if the Ethernet address is un=
icast
>>> + * @addr: Pointer to a six-byte array containing the Ethernet addr=
ess
>>> + *
>>> + * Return true if the address is a unicast address.
>>> + */
>>> +static inline int is_unicast_ether_addr(const u8 *addr)
>>> +{
>>> +	return !is_multicast_ether_addr(addr);
>>> +}
>> Can't you simply use is_valid_ether_addr?
>>
>> I can't think of much reason that a new function for
>> !multicast without the !is_zero is needed.
>>
> performance ?
>
> is_valid_ether_addr() is used at device init time, not when receiving
> packets.
>
> I am not sure we _need_ to check for is_zero_ether_addr() each time w=
e
> receive a packet.
>
> Either a MAC is unicast or multicast.
>
> A zero address is not multicast for sure.

I agree - the is_zero_ether_addr() check seems pointless in the context=
 of
the running interface.

Also, I think a static inline is better form than a #define, all things
being equal.

So, I like Tobias' reworked patches.  I can take them into the Tilera t=
ree,
but I'd prefer David Miller take them into the net tree if he is agreea=
ble,
since it now includes changes to generic networking code.  If you take =
the
latter approach you can include my:

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

--=20
Chris Metcalf, Tilera Corp.
http://www.tilera.com

