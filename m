From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [Bug 4554] New: /proc/net/route missing info for 127.0.0.1/8
Date: Tue, 3 May 2005 19:55:15 -0300
Message-ID: <39e6f6c70505031555691daf80@mail.gmail.com>
References: <20050503143603.4d77d3dd@dxpl.pdx.osdl.net>
	 <4277FDFD.3040501@trash.net>
	 <20050503154709.218626c6@dxpl.pdx.osdl.net>
Reply-To: acme@ghostprotocols.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050503154709.218626c6@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 5/3/05, Stephen Hemminger <shemminger@osdl.org> wrote:
> On Wed, 04 May 2005 00:41:01 +0200
> Patrick McHardy <kaber@trash.net> wrote:
>=20
> > > Distribution: CentOS 4 (RHEL4)
> > > Hardware Environment: i686
> > > Problem Description:
> > > cat /proc/net/route is missing information for 127.0.0.1/8 network =
(lo
> > > interface).  On 2.4 kernels, this info was present (just checked on=
 an old RH7.3
> > > machine).  It seems to be missing on 2.6 kernels.  Bug?  Feature?  =
Omission?
> >
> > 2.4.30 doesn't show it:
> >
> > # route -n
> > Destination     Gateway         Genmask         Flags Metric Ref    U=
se
> > Iface
> > 172.16.0.0      0.0.0.0         255.255.0.0     U     0      0       =
 0 eth0
> >
> > And I'd be surprised if it did, it doesn't include other routes
> > from the local table.
> >
> > Regards
> > Patrick
>=20
> It shows up on our 2.4.18 system, probably it got lost in the fib/seq_p=
rintf
> conversion.
>=20
> $ /sbin/route -n
> Kernel IP routing table
> Destination     Gateway         Genmask         Flags Metric Ref    Use=
 Iface
> 192.168.159.0   172.20.4.11     255.255.255.0   UG    0      0        0=
 eth2
> 172.20.0.0      0.0.0.0         255.255.0.0     U     0      0        0=
 eth2
> 127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0=
 lo
> 0.0.0.0         172.20.0.1      0.0.0.0         UG    0      0        0=
 eth2

[root@toy acme]# route -n
Tabela de Roteamento IP do Kernel
Destino         Roteador        M=E1scaraGen.    Op=E7=F5es M=E9trica Ref=
   Uso Iface
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 e=
th0
172.20.0.0      0.0.0.0         255.255.0.0     U     0      0        0 t=
un0
127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0 l=
o
0.0.0.0         192.168.1.2     0.0.0.0         UG    0      0        0 e=
th0
[root@toy acme]# uname -r
2.6.11-77124cl
[root@toy acme]#

[root@toy acme]# ip r s
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.192
172.20.0.0/16 dev tun0  proto kernel  scope link  src 172.20.0.1
127.0.0.0/8 dev lo  scope link
default via 192.168.1.2 dev eth0
[root@toy acme]#

[root@toy acme]# cat /proc/net/route
Iface   Destination     Gateway         Flags   RefCnt  Use     Metric
 Mask            MTU     Window  IRTT
eth0    0001A8C0        00000000        0001    0       0       0    =20
 00FFFFFF        0       0       0
tun0    000014AC        00000000        0001    0       0       0    =20
 0000FFFF        0       0       0
lo      0000007F        00000000        0001    0       0       0    =20
 000000FF        0       0       0
eth0    00000000        0201A8C0        0003    0       0       0    =20
 00000000        0       0       0
[root@toy acme]#

No problems here.

- Arnaldo
