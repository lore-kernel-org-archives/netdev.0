From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Fri, 06 Jul 2012 12:13:29 +0200
Message-ID: <1341569609.3265.389.camel@edumazet-glaptop>
References: <2d2806e8e8ecad5646524acf2c4c5bcf@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: adam.niescierowicz@justnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49846 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755712Ab2GFKNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 06:13:36 -0400
Received: by eaak11 with SMTP id k11so3559996eaa.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 03:13:34 -0700 (PDT)
In-Reply-To: <2d2806e8e8ecad5646524acf2c4c5bcf@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 11:47 +0200, Nie=C5=9Bcierowicz Adam wrote:
> Hello,
> Can I send something that will help determine the cause of the proble=
m?
>=20
>=20
> W dniu 08.06.2012 11:41, Eric Dumazet napisa=C5=82(a):
>=20
> > On Fri, 2012-06-08 at 10:58 +0200, Nie=C5=9Bcierowicz Adam wrote:
> >
> >> Hello, recently we changed on the router kernel from 2.6.38.1 to=20
> >> 3.4.1
> >> and noticed 30% packet loss when traffic increases up to 250MB / s=
=2E
> >> Similar is for kernel 3.5-rc1 Here a link to ifstat
> >> http://wklej.org/id/767577/ [2]
> >
> > You should give as much as possible delails on your setup (hardware=
,
> > software)
> >
> > lspci
> > cat /proc/cpuinfo
> > cat /proc/interrupts
> > ifconfig -a
> > tc -s -d qdisc
> > dmesg
> > netstat -s
>=20
> currently running on 2.6.38.1 and traffic is 100Mb / s
>=20
> lspci: http://wklej.org/id/769102/
> /proc/cpuinfo: http://wklej.org/id/769104/
> /proc/interrupts: http://wklej.org/id/769106/
> ifconfig -a: http://wklej.org/id/769108/
> tc -s -d qdisc: http://wklej.org/id/769109/
> dmesg: here are some logs from iptables
> netstat -s: http://wklej.org/id/769110/
> lsmod: http://wklej.org/id/769117/
> /proc/net/softnet_stat: http://wklej.org/id/769116/


Same infos of 3.5-rcX kernel would be nice.

What NIC is eth0 ?  (dmesg please)

It seems all network traffic on 2.6.38 is handled by a single cpu (cpu0=
)

(seen in /proc/interrupts)

I suspect that with 3.4 or 3.5 kernels, traffic is handled by many cpus
and they hit false sharing and contention.

You probably get better performance doing some affinity tuning :

=46or example,=20
  eth0 serviced by cpu0
  eth2 serviced by cpu1
  eth3 serviced by cpu2
  eth5 serviced by cpu3

and so on...

check and/or set /proc/irq/${NUM}/smp_affinity
