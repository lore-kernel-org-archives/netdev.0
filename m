From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] tcp: select(writefds) don't hang up when a peer close connection
Date: Thu, 26 Aug 2010 12:09:55 +0900
Message-ID: <AANLkTinPhzMSQ01AXZmDQw8h4OnuS8yoQu7eKog637LL@mail.gmail.com>
References: <20100825110049.F3C9.A69D9226@jp.fujitsu.com>
	<20100825.153424.246521475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:38668 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab0HZDJ4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 23:09:56 -0400
In-Reply-To: <20100825.153424.246521475.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Thank you for quick responce!


>> SUS defined 'ready for writing' of select() as following.
>>
>> | =A0A descriptor shall be considered ready for writing when a call =
to an output
>> | =A0function with O_NONBLOCK clear would not block, whether or not =
the function
>> | =A0would transfer data successfully.
>>
>> That said, EPIPE situation is clearly one of 'ready for writing'.
>
> How Linux should behave is defined by many things, and often it is
> simply defined by how we've behaved for a very long time. =A0This is
> because changing behavior can often break as many applications as it
> can fix. =A0Standards don't necessarily tell us how we must behave,
> since often is it impractical to follow their definions.
>
> And in this case here, I call into question the behavior of Ruby and
> the application from two perspectives:
>
> 1) Unlike all of the other conditions signalled by poll() this is
> =A0 one the application explicitly created and therefore knows about.
>
> =A0 If the application calls close() or shutdown() with the send flag
> =A0 set, IT KNOWS what is going to happen on a write() attempt.

Umm??

Probably my example is not so good. That's not my point.
In the example application, client and server socket is in the same pro=
cess.
But it's NOT generic. usually, client and server are another process. t=
hen,
client can't expect when server close socket.

The most big matter is, this is can't be avoided in userland. In additi=
on,
EVERY application don't want application hang up. we don't hesitate
userland change.

> 2) Ruby and this script will have to deal with the past 13 years
> =A0 worth of Linux kernels. =A0Even if I were to apply this fix now
> =A0 it is not going to propagate onto a user's system any time soon.
>
> =A0 Many systems would never ever get this fix.
>
> =A0 Therefore it behooves Ruby and this script to make a very reasona=
ble
> =A0 change, which is to track when close() or send shutdown() calls o=
ccur
> =A0 and behave appropriately on a write() call.
>
> I'm therefore not applying this patch, because not only can applicati=
ons
> handle this properly with information they already have, the change h=
as
> the potential to break applications.

At first, I was thinking two fix plan.
 1) this patch
 2) adding POLLWRHUP as POLLRDHUP.

However I couldn't find any regression rick in (1). then I did choice (=
1).

So, Can you please tell us what rick you worry? My thinking is, If
select(writefds)
returned, an application naturally call to write. (why not? If not,
why do you call select?)
and write return EPIPE. every network application have EPIPE error chec=
king.

But, there is any rick. I can remake a patch as (2).

Thanks.
