From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: ping -I eth1 ....
Date: Fri, 5 Nov 2010 15:01:57 +0100
Message-ID: <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se> <1288964206.2882.402.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:57575 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751937Ab0KEOCC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 10:02:02 -0400
In-Reply-To: <1288964206.2882.402.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/05 14:36:46:
>
> Le vendredi 05 novembre 2010 =E0 14:14 +0100, Joakim Tjernlund a =E9c=
rit :
> > If I do busybox ping -I eth1 x.x.y.y i see
> > socket(PF_INET, SOCK_RAW, IPPROTO_ICMP) =3D 3
> > getuid()                                =3D 0
> > setuid(0)                               =3D 0
> > setsockopt(3, SOL_SOCKET, SO_BINDTODEVICE, "eth1\0\0\0\0\0\0\0\0\0\=
0\0\0\20\0[l\0\0\0\2\20\7\354(\0"..., 32) =3D 0
> > setsockopt(3, SOL_SOCKET, SO_BROADCAST, [1], 4) =3D 0
> > setsockopt(3, SOL_SOCKET, SO_RCVBUF, [7280], 4) =3D 0
> >
> > ......
> > then this in a loop:
> > --- SIGALRM (Alarm clock) @ 0 (0) ---
> > clock_gettime(CLOCK_MONOTONIC, {1238, 116470107}) =3D 0
> > sendto(3, "\10\0\203\345\1\326\0\2I\314(v\0\0\0\0\0\0\0\0\0\0\0\0".=
=2E., 64, 0, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet=
_addr("1.1.1.1")}, 16) =3D 64
> > rt_sigaction(SIGALRM, {0x10017034, [ALRM], SA_RESTART}, {0x10017034=
, [ALRM], SA_RESTART}, 8) =3D 0
> > alarm(1)                                =3D 0
> > sigreturn()                             =3D ? (mask now [ILL ABRT F=
PE KILL ALRM STKFLT CONT STOP TTOU URG XCPU XFSZ VTALRM PROF WINCH IO P=
WR RTMIN])
> > recvfrom(3, 0xbfe6a620, 192, 0, 0xbfe6a6f0, 0xbfe6a70c) =3D ? EREST=
ARTSYS (To be restarted)
> >
> > Then I do ifconfig eth1 down
> > and I still see the same. Should not
> > sendto and/or revcfrom return some error as
> > the interface is down?
>
> Hmm, this reminds me one patch, yes...
>
> Search for " ipv4: remove all rt cache entries on UNREGISTER event"
>
> http://permalink.gmane.org/gmane.linux.network/173391

Ah, that does the trick. A few comments though:

1) I think you should include IFF_RUNNING too

2) This only affects the TX(sendtoo) path?
   The RX(recvfrom) should also get an error.

   Jocke

>
> I guess I should respin it for net-next-2.6

Yes, pretty please :)

