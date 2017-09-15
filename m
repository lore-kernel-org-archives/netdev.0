From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Fri, 15 Sep 2017 21:04:36 +0200
Message-ID: <12759907.teKvueDKTR@natalenko.name>
References: <10035198.1vE6NFrMDO@natalenko.name> <1760119.uO98D2ft6f@natalenko.name> <CADVnQymkqE+mt4OwtkL1ddpRbqJYPH8CJ0JhNn6ML9YPJdCJxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vulcan.natalenko.name ([104.207.131.136]:44670 "EHLO
        vulcan.natalenko.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdIOTEi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 15:04:38 -0400
In-Reply-To: <CADVnQymkqE+mt4OwtkL1ddpRbqJYPH8CJ0JhNn6ML9YPJdCJxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

With net.ipv4.tcp_fack set to 0 the warning still appears:

=3D=3D=3D
=C2=BB sysctl net.ipv4.tcp_fack    =20
net.ipv4.tcp_fack =3D 0

=C2=BB LC_TIME=3DC dmesg -T | grep WARNING
[Fri Sep 15 20:40:30 2017] WARNING: CPU: 1 PID: 711 at net/ipv4/tcp_input.c:
2826 tcp_fastretrans_alert+0x7c8/0x990
[Fri Sep 15 20:40:30 2017] WARNING: CPU: 0 PID: 711 at net/ipv4/tcp_input.c:
2826 tcp_fastretrans_alert+0x7c8/0x990
[Fri Sep 15 20:48:37 2017] WARNING: CPU: 1 PID: 711 at net/ipv4/tcp_input.c:
2826 tcp_fastretrans_alert+0x7c8/0x990
[Fri Sep 15 20:48:55 2017] WARNING: CPU: 0 PID: 711 at net/ipv4/tcp_input.c:
2826 tcp_fastretrans_alert+0x7c8/0x990

=C2=BB ps -up 711
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root       711  4.3  0.0      0     0 ?        S    18:12   7:23 [irq/123-
enp3s0]
=3D=3D=3D

Any suggestions?

On p=C3=A1tek 15. z=C3=A1=C5=99=C3=AD 2017 16:03:00 CEST Neal Cardwell wrot=
e:
> Thanks for testing that. That is a very useful data point.
>=20
> I was able to cook up a packetdrill test that could put the connection
> in CA_Disorder with retransmitted packets out, but not in CA_Open. So
> we do not yet have a test case to reproduce this.
>=20
> We do not see this warning on our fleet at Google. One significant
> difference I see between our environment and yours is that it seems
> you run with FACK enabled:
>=20
>   net.ipv4.tcp_fack =3D 1
>=20
> Note that FACK was disabled by default (since it was replaced by RACK)
> between kernel v4.10 and v4.11. And this is exactly the time when this
> bug started manifesting itself for you and some others, but not our
> fleet. So my new working hypothesis would be that this warning is due
> to a behavior that only shows up in kernels >=3D4.11 when FACK is
> enabled.
>=20
> Would you be able to disable FACK ("sysctl net.ipv4.tcp_fack=3D0" at
> boot, or net.ipv4.tcp_fack=3D0 in /etc/sysctl.conf, or equivalent),
> reboot, and test the kernel for a few days to see if the warning still
> pops up?
>=20
> thanks,
> neal
>=20
> [ps: apologies for the previous, mis-formatted post...]
