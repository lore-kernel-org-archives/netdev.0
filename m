From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SOMAXCONN = 128, but max defaults to 2048
Date: Sat, 08 Oct 2011 14:35:38 +0200
Message-ID: <1318077339.5276.17.camel@edumazet-laptop>
References: <CAGVGHmt1OVOj0NSEo3qHCh1CR10eZTNjxuUh_mB6sXxcx5gKmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Olaf van der Spek <ml@vdspek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60209 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab1JHMfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 08:35:43 -0400
Received: by wwf22 with SMTP id 22so7124214wwf.1
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 05:35:42 -0700 (PDT)
In-Reply-To: <CAGVGHmt1OVOj0NSEo3qHCh1CR10eZTNjxuUh_mB6sXxcx5gKmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 08 octobre 2011 =C3=A0 13:51 +0200, Olaf van der Spek a =C3=A9=
crit :
> Hi,
>=20
> SOMAXCONN is defined as 128, but the max
> ("/proc/sys/net/ipv4/tcp_max_syn_backlog") appears to be 2048 by
> default.

It depends on memory size and TCP hash table size :

dmesg | grep "TCP established hash table entries"

-> TCP established hash table entries: 524288 (order: 11, 8388608 bytes=
)

sysctl_max_syn_backlog =3D max(128, cnt / 256);
cnt =3D 524288
cnt/256 -> 2048



> Is the name of SOMAXCONN wrong and is it actually defining the defaul=
t?
> Would there be a disadvantage to defining SOMAXCONN as INT_MAX and
> letting the kernel control the actual max?
>=20

You mean : remove somaxconn tunable ?

accept()/listen() is not bound to TCP only.


But yes, 128 default is a bit old today, given that Apache uses a
listen(fd, 511) default value itself...


I routinely set net.core.somaxconn to 1024 on my servers.

We had a recent discussion on the matter lately, but Hagen Paul Pfeifer
did not polish his patches enough :

http://lists.openwall.net/netdev/2011/03/20/3


=46reeBSD has a separate mechanism for not yet established sockets, cal=
led
syncache, that allows a low somaxconn per listener.

The socket queue holds only fully established (but not yet accept()ed)
sockets, while syncache holds all the SYN_RECV ones.
