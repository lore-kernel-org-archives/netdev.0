From: Tom Herbert <tom@herbertland.com>
Subject: Re: Same data to several sockets with just one syscall ?
Date: Fri, 12 Feb 2016 15:25:19 +0100
Message-ID: <CALx6S34dXkRMyW72HKw-j+Qsgrt3P1Xpz1ktf41hoXNak-=cOg@mail.gmail.com>
References: <CAGWmfYrGv8NdJQHs6OA=b=ao8=25JUoZAK_i65+GMFX1OyV-fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Claudio Scordino <claudio@evidence.eu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34004 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbcBLOZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 09:25:20 -0500
Received: by mail-io0-f181.google.com with SMTP id 9so93187952iom.1
        for <netdev@vger.kernel.org>; Fri, 12 Feb 2016 06:25:20 -0800 (PST)
In-Reply-To: <CAGWmfYrGv8NdJQHs6OA=b=ao8=25JUoZAK_i65+GMFX1OyV-fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 12, 2016 at 9:53 AM, Claudio Scordino
<claudio@evidence.eu.com> wrote:
> Hi all.
>
> Suppose I have an application that needs to send the very same data to
> several sockets already connected. In this case, the application has
> to call the sendto() syscall several times:
>
>       for(...)
>                sendto(...)
>
> This makes the application waste time in entering/exiting the kernel
> level several times.
> Moreover, if I'm not wrong, the kernel is free to execute pending work
> (e.g., softirqs) when returning from a syscall, making the application
> experience further latency.
>
> I therefore wonder if a mechanism exists for sending the data to
> several sockets using just a single syscall. If not, has anybody ever
> thought about adding a syscall like the following ?
>
>       sendto-multicast(..., int number_of_sockets, int* const sockets [])
>
> I can't see any obvious reason why such an approach could be wrong.
>
The design of KCM allows for this where sendmmsg can be used to send
messages over TCP to various connections. Overcoming HOL blocking
becomes the biggest issue to address with something like that I think.
Using recvmmsg to get messages from multiple TCP sockets should be
doable in KCM.

Tom

> Many thanks,
>
>                Claudio
