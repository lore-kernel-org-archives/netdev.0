From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Information about napi_struct and net_device
Date: Mon, 29 Oct 2012 00:23:04 +0100
Message-ID: <CALZVapkYdSRB9j+KnXdC7wT9iXqrZvXBcAK=Pk9uFoWwLgDNYg@mail.gmail.com>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
 <1351357421.30380.328.camel@edumazet-glaptop> <20121027182207.GA12858@electric-eye.fr.zoreil.com>
 <1351378943.30380.332.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:61976 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab2J1XXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 19:23:25 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so4706356vcb.19
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 16:23:24 -0700 (PDT)
In-Reply-To: <1351378943.30380.332.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am going to read all the netdevice.h declarations, and try to obtain
a more general view about what does each function do. At the moment,
I've read the page Rami Rosen [1] told be about, but there isn't the
explanation I was looking for, but had links to the netdev conferences
from the past years, and I read many of them.

I wish to ask/state a few questions/words about the napi_struct
creation etc. correct me please if I'm wrong

    1. napi_struct has the fields that usually had net_device about
all control about the polling, so that the device structure where each
driver puts its functions is now much cleaner. With this, though you
have the particular net_device struct it uses in the napi_struct, you
can make as if they would be separated [3].

          a. I need to work with net_device, but I also need to work
with napi_struct, I found these lines of code:
		/*
		 *	Some hardware also needs these fields, but they are not
		 *	part of the usual set specified in Space.c.
		 */

			unsigned long		state;

		struct list_head	dev_list;
		struct list_head	napi_list;
		struct list_head	unreg_list;

              inside of the net_device structure, I know I can take
the net_device pointer as documented in [3], but how may  I obtain the
napi_struct from the netdevice? or I am doing it the wrong way?

    2. I found what napi GRO was in a David S. Miller blog post [2],
which explains many things I found about GRO, that it is about
improving packet processing in the network stack functions.

Javier Domingo

[1]: http://www.linuxfoundation.org/collaborate/workgroups/networking/networkoverview
[2]: http://vger.kernel.org/~davem/cgi-bin/blog.cgi/2010/08/30
[3]: http://lwn.net/Articles/214457/

2012/10/28 Eric Dumazet <eric.dumazet@gmail.com>:
> On Sat, 2012-10-27 at 20:22 +0200, Francois Romieu wrote:
>
>> Not all drivers use napi_gro_receive/napi_gro_flush.
>>
>
> Yes, note that I only mentioned "grep napi", not these specific verbs
>
> Also, napi_gro_receive() could be used now GRO doesnt mandate hardware
> checksums.
>
>> It could be worth comparing with drivers/net/ethernet/via/via-rhine.c (small)
>> or drivers/net/ethernet/broadcom/tg3.c (bigger).
>
> Unfortunately tg3.c uses internal stuff sith napi substring, so I
> ignored it :
>
> $ grep napi drivers/net/ethernet/broadcom/tg3.c | wc -l
> 376
>
>
>
