From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 2 Apr 2010 18:58:28 +0800
Message-ID: <o2j412e6f7f1004020358mf9455fcbqdbb2d762d94a7aa2@mail.gmail.com>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
	<j2u412e6f7f1004012204r76dd8ccbg2e6e78d46541b85@mail.gmail.com>
	<1270193393.1936.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.211.172]:59444 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab0DBK6t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 06:58:49 -0400
Received: by ywh2 with SMTP id 2so1318947ywh.33
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 03:58:48 -0700 (PDT)
In-Reply-To: <1270193393.1936.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 2, 2010 at 3:29 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le vendredi 02 avril 2010 =C3=A0 13:04 +0800, Changli Gao a =C3=A9cri=
t :
>
>
> Your claim of RPS being not good for applications is wrong, our test
> results show an improvement as is. Maybe your applications dont scale=
,
> because of bad habits, or collidings heuristics, I dont know.
>

I didn't mean RPS isn't good for applications. I mean that the
performance improvement of applications isn't as much as firewalls'.
In the other words, we can do much better than the current RPS,  as
RFS does.

>
> Whole point of Herbert patches is you dont need to change application=
s
> and put complex logic in them, knowing exact machine topology.
>
> Your suggestion is very complex, because you must bind each thread on=
 a
> particular cpu, and this is pretty bad for many reasons. We should al=
low
> thread migrations, because scheduler or admin know better than the
> application.
>
> Application writers should rely on standard kernel mechanisms, and
> schedulers, because an application have a limited point of view of wh=
at
> really happens on the machine.
>

Yes, it is more complex. Some high performance server use the
event-driven model, such as memcached, nginx and lighttpd. This model
has high performance on UP with no doubt, and on SMP they usually use
one individual epoll fd for each Core/CPU, and the acceptor dispatches
works among these epoll fds. This program model is popular, and  it
bypass the  system scheduler. I think the socket option SO_RPSCPU can
help this kind of applications work better, why not do that?
Compatility with other Unixes isn't a good cause, for high performance
applications, there are always lots of OS special features used. For
example: epoll vs kqueue, tcp defer accept vs accept filter.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
