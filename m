From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [BUG] Any-IP IPv6 support broken
Date: Mon, 2 Nov 2015 13:30:55 -0800
Message-ID: <CAHo-OoyFi7wZoYvO+i9JEe0yRY+s1Ps9qh9zK02TfEJLuWAmsA@mail.gmail.com>
References: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com>
	<1446132888.7476.153.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHo-OowqDLe1d+bJEo9B_1AC41n+RM+5Kkq7NknA-CouWoeYAQ@mail.gmail.com>
	<C98935CD-7723-4903-A4E2-DEB98DCC5912@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>
To: Gilberto Bertin <gilberto.bertin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:32807 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411AbbKBVa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 16:30:57 -0500
Received: by lfbf136 with SMTP id f136so54051631lfb.0
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 13:30:55 -0800 (PST)
In-Reply-To: <C98935CD-7723-4903-A4E2-DEB98DCC5912@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I would like to have a "bind-to-subnet" semantic with IPv6.

Ah, this is something that I have reason to suspect may indeed be
broken for IPv6.
A coworker did some one-off testing on this a few months back, and
didn't get it to trivially work.
We didn't debug it, nor try to figure out what (if anything) was wrong.

Specifically what we were trying to get is a replacement for the
127.0.0.1/8 subnet on lo, ie. more than one IPv6 loopback IP.

> This is currently working with IPv4, and the setup is the follow:
>
> - setup a dummy network device configured with any-IP
> - add an any-IP route
> - bind() on the dummy device

I'm not entirely sure why you have a dummy device.
Couldn't you use 'lo'?  How are you configuring this?
Any-ip routing configuration explicitly uses iif which should never
trigger here.

> in this way we can effectively bind a process to a particular subnet
> (by binding it to a dummy device which is receiving all the packets
> from a particular subnet).

How can a dummy device receive packets?

> The point of using dummy devices is that we can configure multiple ones
> (and so we can bind multiple processes to multiple subnets).

Interesting, I had no idea something like this was possible.
I'm not convinced this is even working as intended.

Naively I'd expect dummy devices to never be the source of packets,
and thus binding to a dummy device to cause a socket to not receive
any traffic.  But obviously I must be wrong.

> This is actually working with IPv4 (as I said I'm using a recent kernel,
> 4.1), and the fact that you say it's not supposed to work leads me to
> think that maybe we are not talking about the same feature.

Yeah, certainly seems like it.
