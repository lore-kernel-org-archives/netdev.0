From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
	sockets, and for IPv4 multicast forwarding
Date: Wed, 14 Oct 2009 02:50:47 -0700
Message-ID: <55a4f86e0910140250o45532dabr33707c025dfa25f9@mail.gmail.com>
References: <20091007.223928.34412707.davem@davemloft.net>
	 <55a4f86e0910140051v69441b09gd364b32f8e2d0c68@mail.gmail.com>
	 <20091014072319.GA12095@fogou.chygwyn.com>
	 <20091014.021505.181431380.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve@chygwyn.com, atis@mikrotik.com, netdev@vger.kernel.org,
	panther@balabit.hu, eric.dumazet@gmail.com, brian.haley@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:57565 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756586AbZJNJvZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 05:51:25 -0400
Received: by fxm27 with SMTP id 27so11330146fxm.17
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 02:50:47 -0700 (PDT)
In-Reply-To: <20091014.021505.181431380.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problem is the primary purpose of the mark is to enable matching on
the mark in the routing tables.

See 'ip rule  ... fwmark X ...'

ie. that fails due to circular dependency.


On Wed, Oct 14, 2009 at 02:15, David Miller <davem@davemloft.net> wrote=
:
> From: steve@chygwyn.com
> Date: Wed, 14 Oct 2009 08:23:19 +0100
>
>> On Wed, Oct 14, 2009 at 12:51:56AM -0700, Maciej =C5=BBenczykowski w=
rote:
>>> I'm thinking that the mark should be a tunnel parameter with values=
 of
>>> inherit or a constant.
>>>
>> Why not do this on a per-route basis (i.e. lets suppose we add a
>> "setmark" parameter to each route) and this would allow changing
>> a mark when a packet matches the route. This not only solves the
>> tunnel case, but would be generically useful as well.
>>
>> Since we have to look up routes anyway, it shouldn't add any
>> real overhead to the routing process and we can benefit from
>> all the existing infrastructure (route cache, etc).
>
> This idea, I like :-)
>
