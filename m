From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH 06/11] netdev: bfin_mac: avoid tx skb overflows in the tx
	DMA ring
Date: Thu, 20 May 2010 18:23:30 +0800
Message-ID: <AANLkTikDeSLkUCRgnEQlyTbLzorCXTgVD7CIr4mN-xYQ@mail.gmail.com>
References: <AANLkTikKz6v09VTjtANmmcGHU1eKcVWjuDIO24KqkHWK@mail.gmail.com>
	 <20100519.131219.172592870.davem@davemloft.net>
	 <AANLkTimDFWyO8YaNJrWifkYS6g6zSvMZXmtEniCO1wb1@mail.gmail.com>
	 <20100520.030835.267363374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:53845 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab0ETKXb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 06:23:31 -0400
Received: by pxi18 with SMTP id 18so1243996pxi.19
        for <netdev@vger.kernel.org>; Thu, 20 May 2010 03:23:30 -0700 (PDT)
In-Reply-To: <20100520.030835.267363374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 6:08 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Sonic Zhang <sonic.adi@gmail.com>
> Date: Thu, 20 May 2010 17:38:07 +0800
>
>> On Thu, May 20, 2010 at 4:12 AM, David Miller <davem@davemloft.net> =
wrote:
>>> From: Sonic Zhang <sonic.adi@gmail.com>
>>> Date: Wed, 19 May 2010 17:23:16 +0800
>>>
>>>> No, this doesn't happen, because before ndo_start_xmit() returns, =
the
>>>> old TX buffers and skbs in the ring, which finished DMA operation,=
 are
>>>> freed. The only difference is that the free operation of a skb is =
done
>>>> in next tx transfer.
>>>
>>> This is still illegal.
>>>
>>> What if TX activity stops right then, and there is no "next tx
>>> transfer"?
>>>
>> The skb remain in the TX ring will be freed finally when ndo_stop() =
is
>> called to shutdown the network. So, this is not a problem.
>
> You really don't understand me, and I'm starting to get really
> frustrated. =A0You must free all packets in your TX ring in a very
> small, finite, amount of time. =A0This is not optional. =A0And this
> must happen regardless of what TX traffic which occurs in the future,
> that means it must happen even if TX traffic suddenly stops.
>
> Your driver's behavior is absolutely not acceptable.
>
> Leaving the SKB In the TX ring like that means that potentially there
> is a socket in the system or other major resource that cannot be rele=
ased
> and freed up.
>
> Please stop your driver from keeping packets in the TX ring indefinit=
ely.
>

=46orgot to CC netdev mailing list in my last reply.
Try again.

Sonic
