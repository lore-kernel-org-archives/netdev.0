From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 2 Apr 2010 21:45:12 +0800
Message-ID: <x2r412e6f7f1004020645y606f6af1k3fcfc19f08378103@mail.gmail.com>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
	<j2u412e6f7f1004012204r76dd8ccbg2e6e78d46541b85@mail.gmail.com>
	<1270193393.1936.52.camel@edumazet-laptop> <o2j412e6f7f1004020358mf9455fcbqdbb2d762d94a7aa2@mail.gmail.com>
	<1270209708.1989.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:39670 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691Ab0DBNpd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 09:45:33 -0400
Received: by gyg13 with SMTP id 13so967006gyg.19
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 06:45:32 -0700 (PDT)
In-Reply-To: <1270209708.1989.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 2, 2010 at 8:01 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le vendredi 02 avril 2010 =C3=A0 18:58 +0800, Changli Gao a =C3=A9cri=
t :
>
> This dispatch things in UserLand is a poor workaround even if its
> popular (because people try to code portable applications), the hard
> work is already done, this increases latencies and bus traffic.
>
> For short works, that is too expensive.

I'll write a sample program to verify it. For TCP progam, I think it
won't be too expensive.

>
> If you really want to speedup memcached/DNS_server like apps, you mig=
ht
> add a generic mechanism in kernel to split queues of _individual_
> socket.
>
> Aka multiqueue capabilities at socket level. Combined to multiqueue
> devices or RPS, this can be great.
>
>
> That is, an application tells kernel in how many queues incoming UDP
> frames for a given port can be dispatched (number of worker threads)
> No more contention, and this can be done regardless of RPS/RFS.
>
> UDP frame comes in, and is stored on the appropriate sub-queue (can b=
e a
> mapping given by current cpu number). Wakeup the thread that is likel=
y
> running on same cpu.
>
> Same for outgoing frames (answers). You might split the sk_wmemalloc
> thing to make sure several cpus can concurrently use same UDP socket =
to
> send their frames.
>

Yea. It much likes my another idea: selective wakeup. Always try to
wake up the sleeping process which is likely running on the same cpu.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
