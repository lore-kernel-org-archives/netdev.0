From: Claudio Scordino <claudio@evidence.eu.com>
Subject: Re: Same data to several sockets with just one syscall ?
Date: Tue, 16 Feb 2016 08:52:32 +0100
Message-ID: <CAGWmfYp5vz7=tKKLQAJe8o6UP9MduEkNUfyC62DGGAEq4yXP6w@mail.gmail.com>
References: <CAGWmfYrGv8NdJQHs6OA=b=ao8=25JUoZAK_i65+GMFX1OyV-fg@mail.gmail.com>
	<1455273356.31770.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAGWmfYru4zP1n7aSbjtpO4J=aCBfp47B8AV-ACv8XuY-n9E+Hg@mail.gmail.com>
	<1455560180.11190.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:36116 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886AbcBPHwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 02:52:33 -0500
Received: by mail-vk0-f52.google.com with SMTP id c3so126082449vkb.3
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 23:52:33 -0800 (PST)
In-Reply-To: <1455560180.11190.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

2016-02-15 19:16 GMT+01:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Mon, 2016-02-15 at 11:03 +0100, Claudio Scordino wrote:
>> Hi Eric,
>>
>> 2016-02-12 11:35 GMT+01:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> > On Fri, 2016-02-12 at 09:53 +0100, Claudio Scordino wrote:
>> >
>> >> This makes the application waste time in entering/exiting the kernel
>> >> level several times.
>> >
>> > syscall overhead is usually small. Real cost is actually getting to the
>> > socket objects (fd manipulation), that you wont avoid with a
>> > super-syscall anyway.
>>
>> Thank you for answering. I see your point.
>>
>> However, assuming that a switch from user-space to kernel-space (and
>> back) needs about 200nsec of computation (which I guess is a
>> reasonable value for a 3GHz x86 architecture), the 50th receiver
>> experiences a latency of about 10 usec. In some domains (e.g.,
>> finance) this delay is not negligible.
>
> I thought these domains were using multicast.

They don't :)

There are a couple of reasons behind their choice:

- Multicast works only in SOCK_DGRAM (i.e. unreliable)

- For a limited number of receivers (e.g. 50) and depending on the
data size, the latency of multicast is almost equal to the one of TCP

>
>>
>> Moving the "fan-out" code into kernel space would remove this waste of
>> time. IMHO, the latency reduction would pay back the 100 lines of code
>> for adding a new syscall.
>
> It wont reduce the latency at all, and add a lot of maintenance hassle.
>
> syscall overhead is about 40 ns.

I thought it was slightly higher. Does this time also include the
interrupt return to go back to user-space ?


> This is the time taken to transmit ~50 bytes on 10Gbit link.
>
> 40ns * 50 = 2 usec only.
>
> Feel free to implement your idea and test it, you'll discover the added
> complexity is not worth it.

Honestly, I can't see how it could be that difficult: the kernel-side
code could just iterate on the existing syscall...

Can you please elaborate a bit further to let me understand why it
would be that complex ?

Many thanks and best regards,

                 Claudio
