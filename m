From: Peter Chacko <peterchacko35@gmail.com>
Subject: Re: can we reuse an skb
Date: Sun, 21 Jun 2009 11:11:16 +0530
Message-ID: <1f808b4a0906202241l1d74364ft52d99ecb6b0274f5@mail.gmail.com>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com>
	 <4A3BC326.4090203@hp.com>
	 <20090619.162957.156347025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, radhamohan_ch@yahoo.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f197.google.com ([209.85.222.197]:44319 "EHLO
	mail-pz0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbZFUFlO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2009 01:41:14 -0400
Received: by pzk35 with SMTP id 35so100878pzk.33
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2009 22:41:16 -0700 (PDT)
In-Reply-To: <20090619.162957.156347025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here i am considering a special case where Linux stack is not used in
a host environment. Its dedicated packet processor. Application data
is not expected. (discarded if thats the case).

In the case of a host, yes we cannot pre-allocate buffers as it would
requires us to create another copy at the L4  junction. Current memory
allocation for packet buffers are only meant for this case. Not meant
for a special case when the Linux box is a 100% packet processor.I
wish to argue that in this special case, we don't need an skb_alloc()
or skb_free() sorts of interface.

What i am considering here is the super optimization of memory buffers
for a multi-layer packet processor, without needing to move packets
into user space. In that case, i am optimizing my custom network stack
with a pre-allocated MTU sized and a few  jumbo-sized buffers. And no
interrupts as i do NAPI at all times, as this is a dedicated
appliance. I keep all these buffers in the L1 cache and hence i have
different sets of pools for different cores. I  am currently guiding
my engineers to implement the code changes now..

Seeking your advice if any body has done this already or a patch is
available or any advice against this ...

I would greatly appreciate if any one of you could share me your
experience in related work.



Best regards,
Peter chacko.
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
