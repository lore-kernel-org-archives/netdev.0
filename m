From: Yannick Koehler <yannick@koehler.name>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 12:36:50 -0500
Message-ID: <CAJ4BwwGhR_u6JrWanZ3WCPJtkXSPC4O2-boA4XxMw0U1CX+HSg@mail.gmail.com>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
	<kdoibl$978$1@ger.gmane.org>
	<1358951180.12374.787.camel@edumazet-glaptop>
	<CAJ4BwwG-fimMeSD_DSNZZz=Vjz3Qk_58qEnMGv_gmn0rTSeZAg@mail.gmail.com>
	<1358960188.12374.830.camel@edumazet-glaptop>
	<1358961185.12374.853.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:59420 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756574Ab3AWRgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 12:36:52 -0500
Received: by mail-wi0-f176.google.com with SMTP id hm6so950434wib.3
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 09:36:50 -0800 (PST)
In-Reply-To: <1358961185.12374.853.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

  I am not sure to follow you.  I am not changing how sockets works.
I am actually making the af_unix socket works like others, by using
the sndbuf/rcvbuf limits.  The code I added was took from netlink.c
and sock.c (sock_queue_err_skb).  And actually, I am simply "adding" a
limit check, not removing.  The only thing this may do as a negative
side effect is allow more buffer at the same time in the system, but
the global number of buffer remains checked, as it was, if it was,
since I am not changing how buffer gets allocated, just accounted.
Please check my patch.

2013/1/23 Eric Dumazet <eric.dumazet@gmail.com>:
> On Wed, 2013-01-23 at 08:56 -0800, Eric Dumazet wrote:
>
>> You'll have to add proper limits (SO_RCVBUF), accounting the truesize of
>> all accumulated messages.
>
> And if you claim being able to remove DOS attacks, you'll also have to
> add global limits, at a very minimum.
>
> (a la /proc/sys/net/ipv4/tcp_mem or /proc/sys/net/ipv4/udp_mem)
>
> Its not an easy problem, unfortunately.
>
>
>



-- 
Yannick Koehler
Courriel: yannick@koehler.name
Blog: http://corbeillepensees.blogspot.com
