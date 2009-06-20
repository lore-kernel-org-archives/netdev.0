From: Peter Chacko <peterchacko35@gmail.com>
Subject: Re: can we reuse an skb
Date: Sat, 20 Jun 2009 09:24:52 +0530
Message-ID: <1f808b4a0906192054k6182ac2fh1618f0e630033518@mail.gmail.com>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com>
	 <4A3BC326.4090203@hp.com>
	 <20090619.162957.156347025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, radhamohan_ch@yahoo.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f195.google.com ([209.85.222.195]:46737 "EHLO
	mail-pz0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbZFTETb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 00:19:31 -0400
Received: by pzk33 with SMTP id 33so110640pzk.33
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2009 21:19:34 -0700 (PDT)
In-Reply-To: <20090619.162957.156347025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

But if a network application is holding on to a NIC-drive level pooled
buffers,  we also have architectural issues in violating layered
software design. Application plays at a stateful protocol level, while
driver should be stateless and flow-unaware.

Another thought in the lines of radha's original idea:

Assume that we have n-cores capable of processing packet at the same
time. if we trade off memory for computing, why don't we pre-allocate
"n" dedicated skb buffers regardless of the size of each packet, but
just as big as the size of the MTU itself.(forget JUMBO packet for
now).(  today, dev_alloc_skb() allocate based on the packet len, which
is memory usage optimized.).

each dedicated memory buffer is now a per-CPU/thread data structure.

In the  IO stack world , we have buffer cache, identified by buffer
headers. That design was conceived so early as each block level write
was typically 512 bytes and same for all blocks. why don't we adapt
that into network stack ?

Could you share me the problems  with this approach ?


thanks
peter.
On Sat, Jun 20, 2009 at 4:59 AM, David Miller<davem@davemloft.net> wrot=
e:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 19 Jun 2009 09:56:06 -0700
>
>> Assuming a driver did have its own "pool" and didn't rely on the
>> pool(s) from which skbs are drawn, doesn't that mean you have to now
>> have another configuable? =A0There is no good guarantees on when the
>> upper layers will be finished with the skb right? =A0Which means you
>> would be requiring the admin(s) to have an idea of how long their
>> applications wait to pull data from their sockets and configure your
>> driver accordingly.
>>
>> It would seem there would have to be a considerable performance gain
>> demonstrated for that kind of thing?
>
> Applications can hold onto such data "forever" if they want to.
>
> Any scheme which doesn't allow dynamically increasing the pool
> is prone to trivial DoS.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
