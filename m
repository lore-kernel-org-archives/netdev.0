From: Tom Herbert <therbert@google.com>
Subject: Re: RPS vs RFS
Date: Thu, 3 Apr 2014 16:58:43 -0700
Message-ID: <CA+mtBx9aF0XTG8wtBB2W7Be5o3PrbKZ_EWRuSoD73q=gvoT6AQ@mail.gmail.com>
References: <CAJzFV36pTwUyfoW=Jz1tBKSYbZTLvokOLST+XoX593YP6oN7Pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:39292 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbaDCX6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 19:58:44 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so2645043ieb.20
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 16:58:44 -0700 (PDT)
In-Reply-To: <CAJzFV36pTwUyfoW=Jz1tBKSYbZTLvokOLST+XoX593YP6oN7Pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 3, 2014 at 12:14 PM, Sharat Masetty <sharat04@gmail.com> wrote:
> I am trying to understand the true benefit of RFS over RPS. In the
> kernel documentation scaling.txt, the author talks about data cache
> hitrate, can someone explain what this actually means? In which
> scenarios would RFS be beneficial? Why would it help to have network
> stack run on the same core on which the application for a stream/flow
> is running?
>
Silo'ing processing is typically good, it provides cache locality,
potentially eliminates a cross CPU wakeup, and hopefully reduces lock
contention. There is a secondary benefit in that we get some isolation
of RX processing and application.
>
> Consider a NIC with a single receive queue, single interrupt line, and
> iperf application is pulling data off this NIC card. In case where
> iperf may still be running on the same core on which the interrupts
> are delivered, then in that case the whole stack is pinned to the same
> core, and would not be benefiting a lot from this scheme
>
Consider what happens you have a multi threaded network intensive
application like a web server. Running all the networking an a single
CPU becomes a bottleneck (why we created RPS/RFS in the first place).

>
>
>
> References:
> https://www.kernel.org/doc/Documentation/networking/scaling.txt
>
> https://lwn.net/Articles/382428/
>
> Regards,
> Sharat
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
