From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Choppy TCP send performance
Date: Sat, 29 May 2010 00:00:55 +0200
Message-ID: <1275084055.2472.15.camel@edumazet-laptop>
References: <AANLkTilSrX5PifVHlxMjTK-wo_viD8IS_1m1k-vPOlE3@mail.gmail.com>
	 <1275081377.2472.13.camel@edumazet-laptop>
	 <AANLkTilZxoSEGOhmWdk2RbIGMmCMi2yNJm9rUwIzDIoL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tim Heath <theath@greenplum.com>
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:47266 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab0E1WA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 18:00:59 -0400
Received: by wwb28 with SMTP id 28so90044wwb.19
        for <netdev@vger.kernel.org>; Fri, 28 May 2010 15:00:58 -0700 (PDT)
In-Reply-To: <AANLkTilZxoSEGOhmWdk2RbIGMmCMi2yNJm9rUwIzDIoL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 28 mai 2010 =C3=A0 14:35 -0700, Ivan Novick a =C3=A9crit :
> On Fri, May 28, 2010 at 2:16 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le vendredi 28 mai 2010 =C3=A0 13:38 -0700, Ivan Novick a =C3=A9cri=
t :
> >> sk_stream_wait_memory seems to be called when the send buffer is f=
ull
> >> and the next send call does not complete until the send buffer
> >> utilization goes down from 4,194,304 bytes to 2,814,968 bytes.
> >>
> >> This implies that the send that blocks on a full send buffer will =
not
> >> complete until there is 1 meg of free space in the send buffer eve=
n
> >> though the send could be accepted into the OS with only 128KB of f=
ree
> >> space.
> >>
> >
> > static void sock_def_write_space(struct sock *sk)
> > {
> > ...
> > if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D sk->sk_sndbuf) {
> > ...
> >
> >
> > Quick answer is : No, this is not tunable ( independantly than SNDB=
UF )
> >
> > SO_SNDLOWAT is not implemented on linux, yet (its value is : 1).
> >
> >
> > Why would you want to wakeup your thread more than necessary ?
>=20
> Cool.  This helps me understand what is happening.
>=20
> My user thread wants to wake up as soon as the OS can accept my data
> so that it can continue doing work and interact with other components
> in the system.  This is an application issue, i can work around it no=
w
> that i have a better understanding of what the kernel is doing.

If you use poll() or select() before issuing your write(), I believe it
should be OK.



