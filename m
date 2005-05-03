From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [Bug 4554] New: /proc/net/route missing info for 127.0.0.1/8
Date: Wed, 4 May 2005 01:08:24 +0200
Message-ID: <20050503230824.GS577@postel.suug.ch>
References: <20050503143603.4d77d3dd@dxpl.pdx.osdl.net> <4277FDFD.3040501@trash.net> <20050503154709.218626c6@dxpl.pdx.osdl.net> <39e6f6c70505031555691daf80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemminger@osdl.org>, Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@ghostprotocols.net
Content-Disposition: inline
In-Reply-To: <39e6f6c70505031555691daf80@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Arnaldo Carvalho de Melo <39e6f6c70505031555691daf80@mail.gmail.com> 20=
05-05-03 19:55
> [root@toy acme]# route -n
> Tabela de Roteamento IP do Kernel
> Destino         Roteador        M=E1scaraGen.    Op=E7=F5es M=E9trica R=
ef   Uso Iface
> 192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0=
 eth0
> 172.20.0.0      0.0.0.0         255.255.0.0     U     0      0        0=
 tun0
> 127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0=
 lo
> 0.0.0.0         192.168.1.2     0.0.0.0         UG    0      0        0=
 eth0
> [root@toy acme]# uname -r
> 2.6.11-77124cl
> [root@toy acme]#
>=20
> [root@toy acme]# ip r s
> 192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.192
> 172.20.0.0/16 dev tun0  proto kernel  scope link  src 172.20.0.1
> 127.0.0.0/8 dev lo  scope link
> default via 192.168.1.2 dev eth0

Your distribution, scripts, whatever doesn't use the local table
for the loopback route. This gets to be a problem once you add
fib rules and rely on the fact that local routes should have top
priority.

> [root@toy acme]#
>=20
> [root@toy acme]# cat /proc/net/route
> Iface   Destination     Gateway         Flags   RefCnt  Use     Metric
>  Mask            MTU     Window  IRTT
> eth0    0001A8C0        00000000        0001    0       0       0    =20
>  00FFFFFF        0       0       0
> tun0    000014AC        00000000        0001    0       0       0    =20
>  0000FFFF        0       0       0
> lo      0000007F        00000000        0001    0       0       0    =20
>  000000FF        0       0       0
> eth0    00000000        0201A8C0        0003    0       0       0    =20
>  00000000        0       0       0
> [root@toy acme]#

Yes, that's the main routing table. This is a userspace issue.
