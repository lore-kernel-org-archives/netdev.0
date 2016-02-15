From: Claudio Scordino <claudio@evidence.eu.com>
Subject: Re: Same data to several sockets with just one syscall ?
Date: Mon, 15 Feb 2016 11:03:01 +0100
Message-ID: <CAGWmfYru4zP1n7aSbjtpO4J=aCBfp47B8AV-ACv8XuY-n9E+Hg@mail.gmail.com>
References: <CAGWmfYrGv8NdJQHs6OA=b=ao8=25JUoZAK_i65+GMFX1OyV-fg@mail.gmail.com>
	<1455273356.31770.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:34399 "EHLO
	mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbcBOKDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 05:03:02 -0500
Received: by mail-vk0-f50.google.com with SMTP id e185so103359400vkb.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 02:03:01 -0800 (PST)
In-Reply-To: <1455273356.31770.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

2016-02-12 11:35 GMT+01:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Fri, 2016-02-12 at 09:53 +0100, Claudio Scordino wrote:
>
>> This makes the application waste time in entering/exiting the kernel
>> level several times.
>
> syscall overhead is usually small. Real cost is actually getting to the
> socket objects (fd manipulation), that you wont avoid with a
> super-syscall anyway.

Thank you for answering. I see your point.

However, assuming that a switch from user-space to kernel-space (and
back) needs about 200nsec of computation (which I guess is a
reasonable value for a 3GHz x86 architecture), the 50th receiver
experiences a latency of about 10 usec. In some domains (e.g.,
finance) this delay is not negligible.

Moving the "fan-out" code into kernel space would remove this waste of
time. IMHO, the latency reduction would pay back the 100 lines of code
for adding a new syscall.

Many thanks and best regards,

                 Claudio
