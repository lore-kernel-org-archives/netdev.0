From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: Problem with IPSEC tunnel mode
Date: Thu, 21 Apr 2005 16:40:16 +0200
Message-ID: <200504211640.16742.wolfgang.walter@studentenwerk.mhn.de>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Qt7ZC/7Rq7CpG8G"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DObFc-0000je-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_Qt7ZC/7Rq7CpG8G
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Am Donnerstag, 21. April 2005 14:57 schrieb Herbert Xu:
> Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de> wrote:
> > 5. then it disappears (it is NOT dropped by iptables)
> >   especially it is not seen in FORWARD (mangle-table).
> >
> > The route to E on C is a host route via 10.148.15.10.
>
> Please show us the output of "ip ru" and "ip ro".
>

ip ru

0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default

> > src 10.148.4.0/28 dst 10.0.25.210/32
> >        dir in priority 2084
> >        tmpl    src 192.168.9.237 dst 192.168.77.161
> >                proto esp spi 0x00000000 reqid 16465 mode tunnel
> >
> > src 10.148.4.0/28 dst 10.0.25.210/32
> >        dir out priority 0
> >
> > src 10.148.4.0/28 dst 10.0.25.210/32
> >        dir fwd priority 2084
> >        tmpl    src 192.168.9.237 dst 192.168.77.161
> >                proto esp spi 0x00000000 reqid 16465 mode tunnel
>
> Please attach the complete output of "ip x p".

Is attached.

>
> > Interestingly, the original scenario works fine when we use kernel
> > 2.6.7-rc1 instead of 2.6.11.7 and setkey from ipsec-tools 0.3.3. In this
> > case there are
>
> What if you use the new ipsec-tools against the old kernel?

I can try that but can do that only friday evening. Do you expect any=20
difference?

We used ip x p to look at the rules generatet with setkey on that old syste=
m.=20
Actually, setkey could not display these policies (too many rules). The=20
output of ip x p is identical to the above, only no fwd rule at all and all=
=20
rules have the same priority (the order is same, though).

>
> Cheers,

Thanks,

=2D-=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leopoldstra=DFe 15
80802 M=FCnchen

--Boundary-00=_Qt7ZC/7Rq7CpG8G
Content-Type: text/plain;
  charset="iso-8859-15";
  name="01_mail_ro"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="01_mail_ro"

> ip ro

10.0.25.210 via 10.148.15.10 dev eth0.1010  src 10.148.15.9
10.0.25.218 via 10.148.15.22 dev eth0.1013  src 10.148.15.21
10.0.25.155 via 10.148.15.30 dev eth0.1014  src 10.148.15.29
10.0.25.217 via 10.148.15.18 dev eth0.1011  src 10.148.15.17
10.0.25.229 via 10.148.15.6 dev eth0.1012  src 10.148.15.5
10.0.25.52 via 10.148.15.26 dev eth0.1003  src 10.148.15.25
10.0.25.226 via 10.148.15.2 dev eth0.1009  src 10.148.15.1
10.0.25.242 via 10.148.15.2 dev eth0.1009  src 10.148.15.1
192.168.77.160/30 dev eth3  scope link  src 192.168.77.161
10.0.25.156/30 dev eth0.1018  scope link  src 10.0.25.157
10.148.7.40/30 dev eth1.1002  scope link  src 10.148.7.41
10.148.7.36/30 dev eth1.1015  scope link  src 10.148.7.37
10.148.7.32/30 dev eth1.1005  scope link  src 10.148.7.33
10.148.15.32/30 dev eth0.1017  scope link  src 10.148.15.33
10.148.15.28/30 dev eth0.1014  scope link  src 10.148.15.29
10.148.15.24/30 dev eth0.1003  scope link  src 10.148.15.25
10.148.15.20/30 dev eth0.1013  scope link  src 10.148.15.21
10.148.5.0/30 via 10.148.14.2 dev eth1.1016  src 10.148.14.1
10.148.15.16/30 dev eth0.1011  scope link  src 10.148.15.17
10.148.15.8/30 dev eth0.1010  scope link  src 10.148.15.9
10.148.14.0/30 dev eth1.1016  scope link  src 10.148.14.1
10.148.7.8/30 dev eth1.1019  scope link  src 10.148.7.9
10.148.15.4/30 dev eth0.1012  scope link  src 10.148.15.5
10.148.7.0/30 dev eth1.1004  scope link  src 10.148.7.1
10.148.15.0/30 dev eth0.1009  scope link  src 10.148.15.1
10.148.7.48/29 dev eth1.1020  scope link  src 10.148.7.49
10.148.12.32/29 dev eth0.1  scope link  src 10.148.12.33
10.0.25.192/28 dev eth10  scope link  src 10.0.25.193
10.148.4.64/28 dev eth2.1022  scope link  src 10.148.4.65
10.148.12.0/28 dev eth2.1  scope link  src 10.148.12.1
10.148.12.16/28 dev eth1.1  scope link  src 10.148.12.17
10.148.8.128/27 dev eth2.2002  scope link  src 10.148.8.129
10.148.8.0/25 dev eth2.1021  scope link  src 10.148.8.1
10.148.2.0/24 dev eth1.2001  scope link  src 10.148.2.1
192.28.246.0/24 via 10.148.15.34 dev eth0.1017  src 10.148.15.33
10.148.0.0/23 dev eth2.1001  scope link  src 10.148.0.1
10.148.32.0/20 via 10.148.15.30 dev eth0.1014  src 10.148.15.29
default via 192.168.77.162 dev eth3  src 192.168.77.161


--Boundary-00=_Qt7ZC/7Rq7CpG8G
Content-Type: text/plain;
  charset="iso-8859-15";
  name="01_mail_spd"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="01_mail_spd"

src 0.0.0.0/0 dst 255.255.255.255/32 
	dir in priority 0 
src 192.168.9.237/32 dst 192.168.77.161/32 
	dir in priority 0 
src 192.168.99.93/32 dst 192.168.77.161/32 
	dir in priority 0 
src 192.168.99.29/32 dst 192.168.77.161/32 
	dir in priority 0 
src 192.168.99.81/32 dst 192.168.77.161/32 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.32.0/20 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.0.0/23 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.7.40/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.15.4/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.2.0/24 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.15.16/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.229/32 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.4.64/28 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.7.0/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.32.0/20 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.0.0/23 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.7.40/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.15.4/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.2.0/24 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.15.16/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.229/32 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.4.64/28 
	dir in priority 0 
src 192.28.246.0/24 dst 192.28.246.0/24 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.7.48/29 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.242/32 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.7.36/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.226/32 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.15.0/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.15.28/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.15.20/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.192/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.218/32 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.8.0/25 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.8.128/27 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.156/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.12.0/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.155/32 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.7.8/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.210/32 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.12.32/29 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.52/32 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.5.0/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.15.32/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.15.24/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.0.25.217/32 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.14.0/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.12.16/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.15.8/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.7.32/30 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.7.48/29 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.242/32 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.7.36/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.226/32 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.15.0/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.15.28/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.15.20/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.192/28 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.218/32 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.8.0/25 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.8.128/27 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.156/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.12.0/28 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.155/32 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.7.8/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.210/32 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.12.32/29 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.52/32 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.5.0/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.15.32/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.15.24/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.32.0/20 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.0.0/23 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.7.40/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.15.4/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.2.0/24 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.15.16/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.4.64/28 
	dir in priority 0 
src 10.0.25.217/32 dst 192.28.246.0/24 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.7.48/29 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.7.36/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.15.0/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.15.28/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.15.20/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.8.0/25 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.8.128/27 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.12.0/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.7.8/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.12.32/29 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.52/32 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.5.0/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.15.32/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.15.24/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.14.0/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.12.16/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.15.8/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.7.32/30 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.14.0/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.12.16/28 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.15.8/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.7.32/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.32.0/20 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.0.0/23 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.7.40/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.15.4/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.2.0/24 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.15.16/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.229/32 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.4.64/28 
	dir in priority 0 
src 10.148.7.0/30 dst 192.28.246.0/24 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.7.48/29 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.242/32 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.7.36/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.226/32 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.15.0/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.15.28/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.15.20/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.192/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.218/32 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.8.0/25 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.8.128/27 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.156/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.12.0/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.155/32 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.7.8/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.210/32 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.12.32/29 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.52/32 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.5.0/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.15.32/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.15.24/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.0.25.217/32 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.14.0/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.12.16/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.15.8/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.7.32/30 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.7.0/30 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.32.0/20 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.0.0/23 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.7.40/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.15.4/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.2.0/24 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.15.16/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.229/32 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.4.64/28 dst 10.148.12.64/29 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.12.40/29 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.4.0/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.3.0/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.12.48/29 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.4.32/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.3.32/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.4.16/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.4.48/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.3.48/28 
	dir in priority 0 
src 192.28.246.0/24 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.7.48/29 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.242/32 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.7.36/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.226/32 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.15.0/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.15.28/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.15.20/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.192/28 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.218/32 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.8.0/25 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.8.128/27 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.156/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.12.0/28 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.155/32 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.7.8/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.210/32 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.12.32/29 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.52/32 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.5.0/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.15.32/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.15.24/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.12.40/29 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.4.0/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.3.0/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.12.48/29 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.4.32/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.3.32/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.4.16/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.4.48/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.3.48/28 
	dir in priority 0 
src 10.0.25.217/32 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.14.0/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.12.16/28 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.15.8/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.7.32/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.12.40/29 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.4.0/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.3.0/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.12.48/29 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.4.32/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.3.32/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.4.16/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.4.48/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.3.48/28 
	dir in priority 0 
src 10.148.7.0/30 dst 10.148.12.64/29 
	dir in priority 0 
src 10.0.25.218/32 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.218/32 
	dir in priority 0 
src 10.0.25.156/30 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.156/30 
	dir in priority 0 
src 10.0.25.192/28 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.192/28 
	dir in priority 0 
src 10.0.25.229/32 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.229/32 
	dir in priority 0 
src 10.0.25.217/32 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.217/32 
	dir in priority 0 
src 10.0.25.242/32 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.242/32 
	dir in priority 0 
src 10.0.25.155/32 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.155/32 
	dir in priority 0 
src 10.0.25.226/32 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.226/32 
	dir in priority 0 
src 10.0.25.210/32 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.210/32 
	dir in priority 0 
src 10.0.25.52/32 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 10.0.25.52/32 
	dir in priority 0 
src 0.0.0.0/0 dst 192.168.77.161/32 
	dir in priority 0 
src 10.148.12.40/29 dst 10.0.25.155/32 
	dir in priority 2083 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17809 mode tunnel
		
src 10.148.4.16/28 dst 10.0.25.210/32 
	dir in priority 2084 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16877 mode tunnel
		
src 10.148.4.0/28 dst 10.0.25.210/32 
	dir in priority 2084 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16465 mode tunnel
		
src 10.148.4.32/28 dst 10.0.25.210/32 
	dir in priority 2084 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17141 mode tunnel
		
src 10.148.4.0/28 dst 10.0.25.217/32 
	dir in priority 2084 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16873 mode tunnel
		
src 10.148.4.16/28 dst 10.0.25.217/32 
	dir in priority 2084 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16665 mode tunnel
		
src 10.148.4.32/28 dst 10.0.25.217/32 
	dir in priority 2084 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17181 mode tunnel
		
src 10.148.4.0/28 dst 10.148.15.0/30 
	dir in priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17817 mode tunnel
		
src 10.148.4.0/28 dst 10.148.7.0/30 
	dir in priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17541 mode tunnel
		
src 10.148.4.16/28 dst 10.148.7.8/30 
	dir in priority 2148 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17797 mode tunnel
		
src 10.148.4.16/28 dst 10.148.7.0/30 
	dir in priority 2148 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17133 mode tunnel
		
src 10.148.4.16/28 dst 10.148.7.32/30 
	dir in priority 2148 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17285 mode tunnel
		
src 10.148.4.0/28 dst 10.148.7.40/30 
	dir in priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16569 mode tunnel
		
src 10.148.4.0/28 dst 10.148.7.32/30 
	dir in priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17405 mode tunnel
		
src 10.148.4.16/28 dst 10.148.7.40/30 
	dir in priority 2148 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16693 mode tunnel
		
src 10.148.3.0/28 dst 10.148.7.0/30 
	dir in priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16729 mode tunnel
		
src 10.148.3.32/28 dst 10.148.15.24/30 
	dir in priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17805 mode tunnel
		
src 10.148.3.32/28 dst 10.148.14.0/30 
	dir in priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17801 mode tunnel
		
src 10.148.4.32/28 dst 10.148.7.0/30 
	dir in priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16661 mode tunnel
		
src 10.148.4.32/28 dst 10.148.7.32/30 
	dir in priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17521 mode tunnel
		
src 10.148.4.32/28 dst 10.148.7.40/30 
	dir in priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16505 mode tunnel
		
src 10.148.3.32/28 dst 10.148.7.40/30 
	dir in priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17753 mode tunnel
		
src 10.148.3.32/28 dst 10.148.7.0/30 
	dir in priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16485 mode tunnel
		
src 10.148.4.0/28 dst 10.148.15.8/30 
	dir in priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17317 mode tunnel
		
src 10.148.3.0/28 dst 10.148.7.40/30 
	dir in priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17073 mode tunnel
		
src 10.148.4.16/28 dst 192.28.246.0/24 
	dir in priority 2340 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17669 mode tunnel
		
src 10.148.4.16/28 dst 10.148.2.0/24 
	dir in priority 2340 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16917 mode tunnel
		
src 10.148.4.0/28 dst 10.148.2.0/24 
	dir in priority 2340 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16697 mode tunnel
		
src 10.148.3.0/28 dst 10.148.2.0/24 
	dir in priority 2340 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16425 mode tunnel
		
src 10.148.4.32/28 dst 10.148.2.0/24 
	dir in priority 2340 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17009 mode tunnel
		
src 10.148.3.32/28 dst 10.148.2.0/24 
	dir in priority 2340 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16857 mode tunnel
		
src 10.148.3.0/28 dst 10.148.0.0/23 
	dir in priority 2372 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16581 mode tunnel
		
src 10.148.4.0/28 dst 10.148.0.0/23 
	dir in priority 2372 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16845 mode tunnel
		
src 10.148.4.16/28 dst 10.148.0.0/23 
	dir in priority 2372 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16501 mode tunnel
		
src 10.148.4.32/28 dst 10.148.0.0/23 
	dir in priority 2372 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16509 mode tunnel
		
src 10.148.3.32/28 dst 10.148.0.0/23 
	dir in priority 2372 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17757 mode tunnel
		
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in action block priority 65535 
src 0.0.0.0/0 dst 255.255.255.255/32 
	dir out priority 0 
src 192.168.77.161/32 dst 192.168.9.237/32 
	dir out priority 0 
src 192.168.77.161/32 dst 192.168.99.93/32 
	dir out priority 0 
src 192.168.77.161/32 dst 192.168.99.29/32 
	dir out priority 0 
src 192.168.77.161/32 dst 192.168.99.81/32 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.32.0/20 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.32.0/20 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.0.0/23 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.0.0/23 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.7.40/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.7.40/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.15.4/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.15.4/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.2.0/24 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.2.0/24 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.15.16/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.15.16/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.229/32 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.229/32 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.4.64/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.4.64/28 dst 10.148.7.0/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.32.0/20 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.0.0/23 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.7.40/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.15.4/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.2.0/24 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.15.16/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.229/32 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.4.64/28 
	dir out priority 0 
src 192.28.246.0/24 dst 192.28.246.0/24 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.7.48/29 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.242/32 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.7.36/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.226/32 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.15.0/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.15.28/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.15.20/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.192/28 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.218/32 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.8.0/25 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.8.128/27 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.156/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.12.0/28 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.155/32 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.7.8/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.210/32 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.12.32/29 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.52/32 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.5.0/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.15.32/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.15.24/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.0.25.217/32 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.14.0/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.12.16/28 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.15.8/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.7.32/30 
	dir out priority 0 
src 192.28.246.0/24 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.7.48/29 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.7.48/29 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.242/32 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.242/32 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.7.36/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.7.36/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.226/32 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.226/32 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.15.0/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.15.0/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.15.28/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.15.28/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.15.20/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.15.20/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.192/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.192/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.218/32 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.218/32 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.8.0/25 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.8.0/25 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.8.128/27 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.8.128/27 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.156/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.156/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.12.0/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.12.0/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.155/32 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.155/32 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.7.8/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.7.8/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.210/32 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.210/32 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.12.32/29 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.12.32/29 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.52/32 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.52/32 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.5.0/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.5.0/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.15.32/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.15.32/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.15.24/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.15.24/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.32.0/20 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.0.0/23 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.7.40/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.15.4/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.2.0/24 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.15.16/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.4.64/28 
	dir out priority 0 
src 10.0.25.217/32 dst 192.28.246.0/24 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.7.48/29 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.7.36/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.15.0/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.15.28/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.15.20/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.8.0/25 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.8.128/27 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.12.0/28 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.7.8/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.12.32/29 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.52/32 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.5.0/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.15.32/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.15.24/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.14.0/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.12.16/28 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.15.8/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.7.32/30 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.14.0/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.14.0/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.12.16/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.12.16/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.15.8/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.15.8/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.7.32/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.7.32/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.7.0/30 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.7.0/30 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.32.0/20 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.0.0/23 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.7.40/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.15.4/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.2.0/24 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.15.16/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.229/32 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.4.64/28 
	dir out priority 0 
src 10.148.12.40/29 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.4.0/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.3.0/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.12.48/29 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.4.32/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.3.32/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.4.16/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.4.48/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.3.48/28 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.12.64/29 dst 192.28.246.0/24 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.7.48/29 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.242/32 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.7.36/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.226/32 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.15.0/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.15.28/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.15.20/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.192/28 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.218/32 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.8.0/25 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.8.128/27 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.156/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.12.0/28 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.155/32 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.7.8/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.210/32 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.12.32/29 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.52/32 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.5.0/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.15.32/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.15.24/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.4.0/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.3.0/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.12.48/29 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.4.32/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.3.32/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.4.16/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.4.48/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.3.48/28 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.12.64/29 dst 10.0.25.217/32 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.14.0/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.12.16/28 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.15.8/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.7.32/30 
	dir out priority 0 
src 10.148.12.40/29 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.4.0/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.3.0/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.12.48/29 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.4.32/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.3.32/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.4.16/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.4.48/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.3.48/28 dst 10.148.7.0/30 
	dir out priority 0 
src 10.148.12.64/29 dst 10.148.7.0/30 
	dir out priority 0 
src 10.0.25.218/32 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.218/32 
	dir out priority 0 
src 10.0.25.156/30 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.156/30 
	dir out priority 0 
src 10.0.25.192/28 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.192/28 
	dir out priority 0 
src 10.0.25.229/32 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.229/32 
	dir out priority 0 
src 10.0.25.217/32 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.217/32 
	dir out priority 0 
src 10.0.25.242/32 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.242/32 
	dir out priority 0 
src 10.0.25.155/32 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.155/32 
	dir out priority 0 
src 10.0.25.226/32 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.226/32 
	dir out priority 0 
src 10.0.25.210/32 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.210/32 
	dir out priority 0 
src 10.0.25.52/32 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 10.0.25.52/32 
	dir out priority 0 
src 192.168.77.161/32 dst 0.0.0.0/0 
	dir out priority 0 
src 10.0.25.217/32 dst 10.148.12.64/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.12.48/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.52/32 dst 10.148.12.64/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.210/32 dst 10.148.12.64/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.12.48/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.12.40/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.155/32 dst 10.148.12.48/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.52/32 dst 10.148.12.48/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.12.40/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.217/32 dst 10.148.12.48/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.12.64/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.12.64/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.12.64/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.210/32 dst 10.148.12.48/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.226/32 dst 10.148.12.48/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.217/32 dst 10.148.12.40/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.226/32 dst 10.148.12.64/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.226/32 dst 10.148.12.40/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.52/32 dst 10.148.12.40/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.155/32 dst 10.148.12.64/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.210/32 dst 10.148.12.40/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.12.48/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.12.40/29 
	dir out priority 2083 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.155/32 dst 10.148.12.40/29 
	dir out priority 2083 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 17809 mode tunnel
		
src 10.0.25.52/32 dst 10.148.4.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.210/32 dst 10.148.4.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.210/32 dst 10.148.4.0/28 
	dir out priority 2084 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 16465 mode tunnel
		
src 10.0.25.155/32 dst 10.148.3.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.4.16/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.3.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.217/32 dst 10.148.4.16/28 
	dir out priority 2084 
	tmpl	src 192.168.77.161 dst 192.168.99.29
		proto esp spi 0x00000000 reqid 16665 mode tunnel
		
src 10.0.25.155/32 dst 10.148.4.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.52/32 dst 10.148.3.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.4.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.3.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.226/32 dst 10.148.3.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.4.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.52/32 dst 10.148.4.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.217/32 dst 10.148.4.0/28 
	dir out priority 2084 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 16873 mode tunnel
		
src 10.0.25.210/32 dst 10.148.4.16/28 
	dir out priority 2084 
	tmpl	src 192.168.77.161 dst 192.168.99.29
		proto esp spi 0x00000000 reqid 16877 mode tunnel
		
src 10.0.25.217/32 dst 10.148.3.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.155/32 dst 10.148.4.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.155/32 dst 10.148.4.16/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.52/32 dst 10.148.3.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.4.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.226/32 dst 10.148.4.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.4.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.226/32 dst 10.148.4.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.210/32 dst 10.148.3.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.210/32 dst 10.148.3.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.52/32 dst 10.148.4.16/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.217/32 dst 10.148.4.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.217/32 dst 10.148.3.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.226/32 dst 10.148.3.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.210/32 dst 10.148.4.32/28 
	dir out priority 2084 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 17141 mode tunnel
		
src 10.0.25.217/32 dst 10.148.4.32/28 
	dir out priority 2084 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 17181 mode tunnel
		
src 10.0.25.226/32 dst 10.148.4.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.217/32 dst 10.148.3.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.155/32 dst 10.148.3.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.4.16/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.226/32 dst 10.148.4.16/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.3.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.226/32 dst 10.148.3.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.3.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.3.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.3.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.3.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.4.16/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.155/32 dst 10.148.3.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.3.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.3.0/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.52/32 dst 10.148.3.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.4.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.218/32 dst 10.148.4.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.4.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.229/32 dst 10.148.4.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.155/32 dst 10.148.4.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.242/32 dst 10.148.4.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.52/32 dst 10.148.4.32/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.210/32 dst 10.148.3.48/28 
	dir out priority 2084 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.4/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.0/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.16/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.36/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.8/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.156/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.14.0/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.156/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.4/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.8/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.36/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.0/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.16/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.8/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.24/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.36/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.8/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.20/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.0/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.8/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.16/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.24/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.0/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.156/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.4/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.12.40/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.0/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.20/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.14.0/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.20/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.8/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.14.0/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.24/30 dst 10.148.12.64/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.0/30 dst 10.148.12.48/29 
	dir out priority 2147 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.156/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.8/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.156/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.0/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.4/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.0/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 16485 mode tunnel
		
src 10.148.7.36/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 16505 mode tunnel
		
src 10.148.7.8/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.4/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.14.0/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.24/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.4/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 16569 mode tunnel
		
src 10.148.15.20/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.156/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.24/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.0/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 16661 mode tunnel
		
src 10.148.7.8/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.29
		proto esp spi 0x00000000 reqid 16693 mode tunnel
		
src 10.148.7.36/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.14.0/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.0/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 16729 mode tunnel
		
src 10.148.15.16/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.20/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.24/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.0/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.156/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.14.0/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.8/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.36/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.36/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.16/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.14.0/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.36/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 17073 mode tunnel
		
src 10.148.7.36/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.0/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.0/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.8/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.0/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.29
		proto esp spi 0x00000000 reqid 17133 mode tunnel
		
src 10.0.25.156/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.4/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.8/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.4/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.20/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.0/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.0/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.29
		proto esp spi 0x00000000 reqid 17285 mode tunnel
		
src 10.148.15.4/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.8/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.14.0/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.8/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 17317 mode tunnel
		
src 10.148.14.0/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.20/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.24/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.16/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 17405 mode tunnel
		
src 10.148.15.8/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.24/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.8/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.8/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.20/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.16/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.36/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.16/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.32/30 dst 10.148.4.32/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 17521 mode tunnel
		
src 10.148.7.0/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 17541 mode tunnel
		
src 10.148.15.0/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.8/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.20/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.156/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.8/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.16/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.32/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.5.0/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.0/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.4/30 dst 10.148.3.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.20/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.16/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.40/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 17753 mode tunnel
		
src 10.0.25.156/30 dst 10.148.4.48/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.28/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.15.24/30 dst 10.148.3.0/28 
	dir out priority 2148 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.8/30 dst 10.148.4.16/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.29
		proto esp spi 0x00000000 reqid 17797 mode tunnel
		
src 10.148.14.0/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 17801 mode tunnel
		
src 10.148.15.24/30 dst 10.148.3.32/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 17805 mode tunnel
		
src 10.148.15.0/30 dst 10.148.4.0/28 
	dir out priority 2148 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 17817 mode tunnel
		
src 10.148.12.32/29 dst 10.148.12.48/29 
	dir out priority 2179 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.12.48/29 
	dir out priority 2179 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.12.64/29 
	dir out priority 2179 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.32/29 dst 10.148.12.64/29 
	dir out priority 2179 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.12.40/29 
	dir out priority 2179 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.32/29 dst 10.148.12.40/29 
	dir out priority 2179 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.4.16/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.3.32/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.3.48/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.4.32/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.4.48/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.32/29 dst 10.148.4.16/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.4.0/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.32/29 dst 10.148.3.32/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.32/29 dst 10.148.3.0/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.32/29 dst 10.148.4.32/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.32/29 dst 10.148.3.48/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.7.48/29 dst 10.148.3.0/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.32/29 dst 10.148.4.0/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.32/29 dst 10.148.4.48/28 
	dir out priority 2180 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.12.48/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.12.48/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.12.40/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.12.64/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.12.64/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.12.64/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.12.64/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.12.40/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.12.48/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.12.48/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.12.40/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.12.40/29 
	dir out priority 2211 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.4.0/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.4.32/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.3.0/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.3.32/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.4.16/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.3.0/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.4.0/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.3.48/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.4.32/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.4.48/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.4.16/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.3.48/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.4.0/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.4.0/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.3.32/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.3.0/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.4.48/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.4.32/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.3.32/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.4.64/28 dst 10.148.4.16/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.3.48/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.4.32/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.3.0/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.16/28 dst 10.148.4.48/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.3.48/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.4.16/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.12.0/28 dst 10.148.3.32/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.0.25.192/28 dst 10.148.4.48/28 
	dir out priority 2212 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.12.64/29 
	dir out priority 2243 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.12.40/29 
	dir out priority 2243 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.12.48/29 
	dir out priority 2243 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.3.0/28 
	dir out priority 2244 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.3.32/28 
	dir out priority 2244 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.4.32/28 
	dir out priority 2244 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.3.48/28 
	dir out priority 2244 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.4.16/28 
	dir out priority 2244 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.4.0/28 
	dir out priority 2244 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.128/27 dst 10.148.4.48/28 
	dir out priority 2244 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.12.64/29 
	dir out priority 2307 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.12.40/29 
	dir out priority 2307 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.12.48/29 
	dir out priority 2307 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.4.32/28 
	dir out priority 2308 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.4.48/28 
	dir out priority 2308 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.3.0/28 
	dir out priority 2308 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.4.16/28 
	dir out priority 2308 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.4.0/28 
	dir out priority 2308 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.3.32/28 
	dir out priority 2308 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.8.0/25 dst 10.148.3.48/28 
	dir out priority 2308 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.2.0/24 dst 10.148.12.40/29 
	dir out priority 2339 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.2.0/24 dst 10.148.12.48/29 
	dir out priority 2339 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 192.28.246.0/24 dst 10.148.12.40/29 
	dir out priority 2339 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 192.28.246.0/24 dst 10.148.12.64/29 
	dir out priority 2339 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 192.28.246.0/24 dst 10.148.12.48/29 
	dir out priority 2339 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.2.0/24 dst 10.148.12.64/29 
	dir out priority 2339 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.2.0/24 dst 10.148.3.0/28 
	dir out priority 2340 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 16425 mode tunnel
		
src 10.148.2.0/24 dst 10.148.4.0/28 
	dir out priority 2340 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 16697 mode tunnel
		
src 192.28.246.0/24 dst 10.148.3.48/28 
	dir out priority 2340 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.2.0/24 dst 10.148.3.32/28 
	dir out priority 2340 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 16857 mode tunnel
		
src 192.28.246.0/24 dst 10.148.3.0/28 
	dir out priority 2340 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.2.0/24 dst 10.148.4.16/28 
	dir out priority 2340 
	tmpl	src 192.168.77.161 dst 192.168.99.29
		proto esp spi 0x00000000 reqid 16917 mode tunnel
		
src 192.28.246.0/24 dst 10.148.4.48/28 
	dir out priority 2340 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.2.0/24 dst 10.148.4.32/28 
	dir out priority 2340 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 17009 mode tunnel
		
src 10.148.2.0/24 dst 10.148.3.48/28 
	dir out priority 2340 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.2.0/24 dst 10.148.4.48/28 
	dir out priority 2340 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 192.28.246.0/24 dst 10.148.3.32/28 
	dir out priority 2340 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 192.28.246.0/24 dst 10.148.4.32/28 
	dir out priority 2340 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 192.28.246.0/24 dst 10.148.4.16/28 
	dir out priority 2340 
	tmpl	src 192.168.77.161 dst 192.168.99.29
		proto esp spi 0x00000000 reqid 17669 mode tunnel
		
src 192.28.246.0/24 dst 10.148.4.0/28 
	dir out priority 2340 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.0.0/23 dst 10.148.12.48/29 
	dir out priority 2371 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.0.0/23 dst 10.148.12.40/29 
	dir out priority 2371 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.0.0/23 dst 10.148.12.64/29 
	dir out priority 2371 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.0.0/23 dst 10.148.4.48/28 
	dir out priority 2372 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.0.0/23 dst 10.148.4.16/28 
	dir out priority 2372 
	tmpl	src 192.168.77.161 dst 192.168.99.29
		proto esp spi 0x00000000 reqid 16501 mode tunnel
		
src 10.148.0.0/23 dst 10.148.4.32/28 
	dir out priority 2372 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 16509 mode tunnel
		
src 10.148.0.0/23 dst 10.148.3.0/28 
	dir out priority 2372 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 16581 mode tunnel
		
src 10.148.0.0/23 dst 10.148.4.0/28 
	dir out priority 2372 
	tmpl	src 192.168.77.161 dst 192.168.9.237
		proto esp spi 0x00000000 reqid 16845 mode tunnel
		
src 10.148.0.0/23 dst 10.148.3.48/28 
	dir out priority 2372 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.0.0/23 dst 10.148.3.32/28 
	dir out priority 2372 
	tmpl	src 192.168.77.161 dst 192.168.99.93
		proto esp spi 0x00000000 reqid 17757 mode tunnel
		
src 10.148.32.0/20 dst 10.148.12.40/29 
	dir out priority 2467 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.32.0/20 dst 10.148.12.48/29 
	dir out priority 2467 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.32.0/20 dst 10.148.12.64/29 
	dir out priority 2467 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.32.0/20 dst 10.148.4.0/28 
	dir out priority 2468 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.32.0/20 dst 10.148.3.32/28 
	dir out priority 2468 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.32.0/20 dst 10.148.4.16/28 
	dir out priority 2468 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.32.0/20 dst 10.148.4.32/28 
	dir out priority 2468 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.32.0/20 dst 10.148.3.48/28 
	dir out priority 2468 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.32.0/20 dst 10.148.3.0/28 
	dir out priority 2468 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 10.148.32.0/20 dst 10.148.4.48/28 
	dir out priority 2468 
	tmpl	src 0.0.0.0 dst 0.0.0.0
		proto esp spi 0x00000000 reqid 0 mode transport
		
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out action block priority 65535 
src 10.148.32.0/20 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.7.0/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.32.0/20 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.0.0/23 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.7.40/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.15.4/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.2.0/24 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.15.16/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.229/32 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.4.64/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 192.28.246.0/24 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.7.48/29 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.242/32 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.7.36/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.226/32 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.15.0/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.15.28/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.15.20/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.192/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.218/32 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.8.0/25 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.8.128/27 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.156/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.12.0/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.155/32 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.7.8/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.210/32 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.12.32/29 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.52/32 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.5.0/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.15.32/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.15.24/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.0.25.217/32 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.14.0/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.12.16/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.15.8/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.7.32/30 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.32.0/20 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.0.0/23 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.7.40/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.15.4/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.2.0/24 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.15.16/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.4.64/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 192.28.246.0/24 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.7.48/29 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.7.36/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.15.0/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.15.28/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.15.20/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.8.0/25 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.8.128/27 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.12.0/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.7.8/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.12.32/29 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.5.0/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.15.32/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.15.24/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.14.0/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.12.16/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.15.8/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.7.32/30 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.7.0/30 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.32.0/20 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.0.0/23 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.7.40/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.15.4/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.2.0/24 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.15.16/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.4.64/28 dst 10.148.12.64/29 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.12.40/29 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.4.0/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.3.0/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.12.48/29 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.4.32/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.3.32/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.4.16/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.4.48/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.3.48/28 
	dir fwd priority 0 
src 192.28.246.0/24 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.7.48/29 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.242/32 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.7.36/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.226/32 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.15.0/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.15.28/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.15.20/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.192/28 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.218/32 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.8.0/25 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.8.128/27 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.156/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.12.0/28 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.155/32 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.7.8/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.210/32 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.12.32/29 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.52/32 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.5.0/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.15.32/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.15.24/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.0.25.217/32 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.14.0/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.12.16/28 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.15.8/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.7.32/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.12.40/29 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.4.0/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.3.0/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.12.48/29 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.4.32/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.3.32/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.4.16/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.4.48/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.3.48/28 
	dir fwd priority 0 
src 10.148.7.0/30 dst 10.148.12.64/29 
	dir fwd priority 0 
src 10.0.25.218/32 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.218/32 
	dir fwd priority 0 
src 10.0.25.156/30 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.156/30 
	dir fwd priority 0 
src 10.0.25.192/28 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.192/28 
	dir fwd priority 0 
src 10.0.25.229/32 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.229/32 
	dir fwd priority 0 
src 10.0.25.217/32 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.217/32 
	dir fwd priority 0 
src 10.0.25.242/32 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.242/32 
	dir fwd priority 0 
src 10.0.25.155/32 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.155/32 
	dir fwd priority 0 
src 10.0.25.226/32 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.226/32 
	dir fwd priority 0 
src 10.0.25.210/32 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.210/32 
	dir fwd priority 0 
src 10.0.25.52/32 dst 0.0.0.0/0 
	dir fwd priority 0 
src 0.0.0.0/0 dst 10.0.25.52/32 
	dir fwd priority 0 
src 10.148.12.40/29 dst 10.0.25.155/32 
	dir fwd priority 2083 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17809 mode tunnel
		
src 10.148.4.16/28 dst 10.0.25.210/32 
	dir fwd priority 2084 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16877 mode tunnel
		
src 10.148.4.0/28 dst 10.0.25.210/32 
	dir fwd priority 2084 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16465 mode tunnel
		
src 10.148.4.32/28 dst 10.0.25.210/32 
	dir fwd priority 2084 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17141 mode tunnel
		
src 10.148.4.0/28 dst 10.0.25.217/32 
	dir fwd priority 2084 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16873 mode tunnel
		
src 10.148.4.16/28 dst 10.0.25.217/32 
	dir fwd priority 2084 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16665 mode tunnel
		
src 10.148.4.32/28 dst 10.0.25.217/32 
	dir fwd priority 2084 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17181 mode tunnel
		
src 10.148.4.0/28 dst 10.148.15.0/30 
	dir fwd priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17817 mode tunnel
		
src 10.148.4.0/28 dst 10.148.7.0/30 
	dir fwd priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17541 mode tunnel
		
src 10.148.4.16/28 dst 10.148.7.8/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17797 mode tunnel
		
src 10.148.4.16/28 dst 10.148.7.0/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17133 mode tunnel
		
src 10.148.4.16/28 dst 10.148.7.32/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17285 mode tunnel
		
src 10.148.4.0/28 dst 10.148.7.40/30 
	dir fwd priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16569 mode tunnel
		
src 10.148.4.0/28 dst 10.148.7.32/30 
	dir fwd priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17405 mode tunnel
		
src 10.148.4.16/28 dst 10.148.7.40/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16693 mode tunnel
		
src 10.148.3.0/28 dst 10.148.7.0/30 
	dir fwd priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16729 mode tunnel
		
src 10.148.3.32/28 dst 10.148.15.24/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17805 mode tunnel
		
src 10.148.3.32/28 dst 10.148.14.0/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17801 mode tunnel
		
src 10.148.4.32/28 dst 10.148.7.0/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16661 mode tunnel
		
src 10.148.4.32/28 dst 10.148.7.32/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17521 mode tunnel
		
src 10.148.4.32/28 dst 10.148.7.40/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16505 mode tunnel
		
src 10.148.3.32/28 dst 10.148.7.40/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17753 mode tunnel
		
src 10.148.3.32/28 dst 10.148.7.0/30 
	dir fwd priority 2148 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16485 mode tunnel
		
src 10.148.4.0/28 dst 10.148.15.8/30 
	dir fwd priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17317 mode tunnel
		
src 10.148.3.0/28 dst 10.148.7.40/30 
	dir fwd priority 2148 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17073 mode tunnel
		
src 10.148.4.16/28 dst 192.28.246.0/24 
	dir fwd priority 2340 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17669 mode tunnel
		
src 10.148.4.16/28 dst 10.148.2.0/24 
	dir fwd priority 2340 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16917 mode tunnel
		
src 10.148.4.0/28 dst 10.148.2.0/24 
	dir fwd priority 2340 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16697 mode tunnel
		
src 10.148.3.0/28 dst 10.148.2.0/24 
	dir fwd priority 2340 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16425 mode tunnel
		
src 10.148.4.32/28 dst 10.148.2.0/24 
	dir fwd priority 2340 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17009 mode tunnel
		
src 10.148.3.32/28 dst 10.148.2.0/24 
	dir fwd priority 2340 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16857 mode tunnel
		
src 10.148.3.0/28 dst 10.148.0.0/23 
	dir fwd priority 2372 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16581 mode tunnel
		
src 10.148.4.0/28 dst 10.148.0.0/23 
	dir fwd priority 2372 
	tmpl	src 192.168.9.237 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16845 mode tunnel
		
src 10.148.4.16/28 dst 10.148.0.0/23 
	dir fwd priority 2372 
	tmpl	src 192.168.99.29 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16501 mode tunnel
		
src 10.148.4.32/28 dst 10.148.0.0/23 
	dir fwd priority 2372 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 16509 mode tunnel
		
src 10.148.3.32/28 dst 10.148.0.0/23 
	dir fwd priority 2372 
	tmpl	src 192.168.99.93 dst 192.168.77.161
		proto esp spi 0x00000000 reqid 17757 mode tunnel
		
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir fwd action block priority 65535 

--Boundary-00=_Qt7ZC/7Rq7CpG8G--
