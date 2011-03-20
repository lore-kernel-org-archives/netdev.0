From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] socket: increase default maximum listen queue length
Date: Sun, 20 Mar 2011 12:55:44 +0100
Message-ID: <1300622144.2831.287.camel@edumazet-laptop>
References: <1300585811-21566-1-git-send-email-hagen@jauu.net>
	 <1300609817.2831.56.camel@edumazet-laptop>
	 <20110320113921.GA3038@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38648 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab1CTLzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 07:55:53 -0400
Received: by bwz15 with SMTP id 15so4412111bwz.19
        for <netdev@vger.kernel.org>; Sun, 20 Mar 2011 04:55:52 -0700 (PDT)
In-Reply-To: <20110320113921.GA3038@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 20 mars 2011 =C3=A0 12:39 +0100, Hagen Paul Pfeifer a =C3=A9=
crit :
> * Eric Dumazet | 2011-03-20 09:30:17 [+0100]:
>=20
> >Hmm, real problem is not the 'maximum queue value', but the minimum =
one.
> >
> >If application says : listen(fd, 10), you are stuck.
> >
> >128 or 256 is way too small on some servers, where admin can tune
> >in /etc/sysctl.conf :
> >
> >net.core.somaxconn =3D 8192
> >net.ipv4.tcp_max_syn_backlog =3D 8192
> >
> >But application also needs to use : listen(fd, 8192)
>=20
> I know Eric, I wrote the patch. ;-) The used naming goes like this:
>=20
> The system limits (somaxconn & tcp_max_syn_backlog) specify a _maximu=
m_, the
> user cannot exceed this limit with listen(2). The backlog argument fo=
r listen
> on the other hand specify a _minimum_. But the patch increased the de=
fault
> maximum, therefore I named it in this way.


I am not sure you understood what I said.

Even if you change kernel limits, many applications still use low
limits : listen(fd, 8)

I remember some other OS (was it HPUX or Solaris...) had a minimum
limit : Even if application said 8, an admin could impose a 256 value
for example.

=46rankly, I believe somaxconn should be a default enforcement, that a
particular protocol could override.

TCP sockets for example should only enforce tcp_max_syn_backlog limit,
not the somaxconn & tcp_max_syn_backlog.



