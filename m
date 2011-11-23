From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: cache forver in 3.2.0-rc2-00400-g866d43c ?
Date: Wed, 23 Nov 2011 19:22:21 +0100
Message-ID: <1322072541.2775.1.camel@edumazet-laptop>
References: <201111231910.37190.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Arkadiusz =?UTF-8?Q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:39584 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346Ab1KWSW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 13:22:26 -0500
Received: by yenq3 with SMTP id q3so1701372yen.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 10:22:26 -0800 (PST)
In-Reply-To: <201111231910.37190.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 novembre 2011 =C3=A0 19:10 +0100, Arkadiusz Mi=C5=9Bkiew=
icz a
=C3=A9crit :
> Hello,
>=20
> I'm using  my notebook in two different networks, suspending and resu=
ming from=20
> ram between.
>=20
> Network A (192.168.1.0/24) has server with IP 87.204.99.133 in the sa=
me lan.=20
> Now when I suspend, go to totally different network B (different prov=
ider,=20
> different lan, 192.168.0.0/24) and resume then I'm unable to connect =
to=20
> 87.204.99.133.
>=20
> Looks like network stack thinks that 87...133 is still directly reach=
able on=20
> eth1and I'm unable to make it forget that.
>=20
> [root@t400 ~]# ip ne flush dev eth1; ip r flush table cache
> [root@t400 ~]# ip r show table cache to 87.204.99.133
> [root@t400 ~]# ping -c 1 87.204.99.133
> PING 87.204.99.133 (87.204.99.133) 56(84) bytes of data.
> From 192.168.0.5: icmp_seq=3D1 Destination Host Unreachable
>=20
> --- 87.204.99.133 ping statistics ---
> 1 packets transmitted, 0 received, +1 errors, 100% packet loss, time =
0ms
>=20
> zsh: exit 1     ping -c 1 87.204.99.133
> [root@t400 ~]# ip r show table cache to 87.204.99.133
> 87.204.99.133 dev eth1  src 192.168.0.5
>     cache <redirected>  ipid 0x2838 rtt 17ms rttvar 12ms cwnd 10
> 87.204.99.133 from 192.168.0.5 dev eth1
>     cache <redirected>  ipid 0x2838 rtt 17ms rttvar 12ms cwnd 10
> [root@t400 ~]# ip ne show to 87.204.99.133
> 87.204.99.133 dev eth1  FAILED
>=20
> tcpdump in meantime sees this:
> 19:06:26.907153 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has=20
> 87.204.99.133 tell 192.168.0.5, length 28
> 19:06:27.908379 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has=20
> 87.204.99.133 tell 192.168.0.5, length 28
> 19:06:28.907084 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has=20
> 87.204.99.133 tell 192.168.0.5, length 28
> 19:06:29.907145 IP (tos 0xc0, ttl 64, id 34465, offset 0, flags [none=
], proto=20
> ICMP (1), length 112)
>     192.168.0.5 > 192.168.0.5: ICMP host 87.204.99.133 unreachable, l=
ength 92
>         IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (=
1),=20
> length 84)
>     192.168.0.5 > 87.204.99.133: ICMP echo request, id 17590, seq 1, =
length 64
>=20
> Any ideas?
>=20
> Thanks,

Hmm, could you check you have this fix in your tree ?

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net.git;a=3Dcommit;h=
=3D9cc20b268a5a14f5e57b8ad405a83513ab0d78dc
