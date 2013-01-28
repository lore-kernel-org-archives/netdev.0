From: Michael Leun <lkml20130126-yS7QfQBdiAdyjo5WHAzKoQ@public.gmane.org>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Mon, 28 Jan 2013 17:42:07 +0100
Message-ID: <20130128174207.1a38283d@xenia>
References: <1358908337-13841-1-git-send-email-freddy@asix.com.tw>
	<20130127001347.584711b2@xenia>
	<87zjztptez.fsf@nemi.mork.no>
	<010f01cdfd5c$768d4240$63a7c6c0$@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "=?ISO-8859-15?B?J0Jq+HJu?= Mork'" <bjorn-yOkvZcmFvRU@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <Support-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: "Freddy" <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <010f01cdfd5c$768d4240$63a7c6c0$@asix.com.tw>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Jan 2013 21:36:20 +0800
"Freddy" <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org> wrote:

> > I would vote to not accept that driver for mainline as long as this=
=20
> > issues are not fixed.
>=20
>=20
> Michael, could you give me more information about how do you test
> this driver? I have tried to reproduce the issue by using "ifconfig
> ethX mtu 1500", but I didn't confront the same issue. Thank you in
> advance for your help.

I'm very sorry, but this seems to be some mistake on my side. I would
have sworn that I had done this also with mtu 1500, but now it looks
like you have to set the mtu to at least 1519 to see the issue (likely
an typo and I actually had set it to 1600):

jill:/home/ml # ifconfig eth3 192.168.123.2/24
jill:/home/ml # ifconfig eth3
eth3      Link encap:Ethernet  Hardware Adresse 00:24:9B:05:5C:E3 =20
          inet Adresse:192.168.123.2  Bcast:192.168.123.255  Maske:255.=
255.255.0
          inet6 Adresse: fe80::224:9bff:fe05:5ce3/64 G=FCltigkeitsberei=
ch:Verbindung
          UP BROADCAST RUNNING MULTICAST  MTU:1488  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 Sendewarteschlangenl=E4nge:1000=20
          RX bytes:0 (0.0 b)  TX bytes:98 (98.0 b)

jill:/home/ml # ping 192.168.123.1
PING 192.168.123.1 (192.168.123.1) 56(84) bytes of data.
64 bytes from 192.168.123.1: icmp_seq=3D1 ttl=3D64 time=3D1.41 ms
64 bytes from 192.168.123.1: icmp_seq=3D2 ttl=3D64 time=3D0.969 ms
64 bytes from 192.168.123.1: icmp_seq=3D3 ttl=3D64 time=3D1.01 ms
^C
--- 192.168.123.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev =3D 0.969/1.131/1.412/0.199 ms
jill:/home/ml # ping -s 1491 192.168.123.1
PING 192.168.123.1 (192.168.123.1) 1491(1519) bytes of data.
1499 bytes from 192.168.123.1: icmp_seq=3D1 ttl=3D64 time=3D1.30 ms
1499 bytes from 192.168.123.1: icmp_seq=3D2 ttl=3D64 time=3D1.10 ms
1499 bytes from 192.168.123.1: icmp_seq=3D3 ttl=3D64 time=3D1.24 ms
^C
--- 192.168.123.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev =3D 1.109/1.218/1.306/0.086 ms
jill:/home/ml # ifconfig eth3 mtu 1519
jill:/home/ml # ping 192.168.123.1
PING 192.168.123.1 (192.168.123.1) 56(84) bytes of data.
64 bytes from 192.168.123.1: icmp_seq=3D1 ttl=3D64 time=3D1.11 ms
64 bytes from 192.168.123.1: icmp_seq=3D2 ttl=3D64 time=3D0.969 ms
^C
--- 192.168.123.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev =3D 0.969/1.042/1.115/0.073 ms
jill:/home/ml # ping -s 1491 192.168.123.1
PING 192.168.123.1 (192.168.123.1) 1491(1519) bytes of data.
^C
--- 192.168.123.1 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1000ms

jill:/home/ml # ping 192.168.123.1
PING 192.168.123.1 (192.168.123.1) 56(84) bytes of data.
^C
--- 192.168.123.1 ping statistics ---
6 packets transmitted, 0 received, 100% packet loss, time 4999ms

jill:/home/ml #=20

--=20
MfG,

Michael Leun

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
