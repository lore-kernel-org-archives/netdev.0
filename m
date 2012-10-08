From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Mon, 08 Oct 2012 08:22:53 +0200
Message-ID: <1349677373.21172.2756.camel@edumazet-glaptop>
References: <409ac8b30a6994028562e1a159ac60aa@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: adam.niescierowicz@justnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:48711 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab2JHGXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 02:23:11 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so2349442wey.19
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 23:23:09 -0700 (PDT)
In-Reply-To: <409ac8b30a6994028562e1a159ac60aa@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-07 at 21:18 +0200, Nie=C5=9Bcierowicz Adam wrote:
> W dniu 06.07.2012 12:13, Eric Dumazet napisa=C5=82(a):
>=20
> > On Fri, 2012-07-06 at 11:47 +0200, Nie=C5=9Bcierowicz Adam wrote:
> >
> >> Hello, Can I send something that will help determine the cause of=20
> >> the
> >> problem? W dniu 08.06.2012 11:41, Eric Dumazet napisa=C5=82(a):
> >>
> >>> On Fri, 2012-06-08 at 10:58 +0200, Nie=C5=9Bcierowicz Adam wrote:
> >>>
> >>>> Hello, recently we changed on the router kernel from 2.6.38.1 to
> >>>> 3.4.1 and noticed 30% packet loss when traffic increases up to
> >>>> 250MB / s. Similar is for kernel 3.5-rc1 Here a link to ifstat
> >>>> http://wklej.org/id/767577/ [1] [2]
> >>> You should give as much as possible delails on your setup=20
> >>> (hardware,
> >>> software) lspci cat /proc/cpuinfo cat /proc/interrupts ifconfig -=
a=20
> >>> tc
> >>> -s -d qdisc dmesg netstat -s
> >> currently running on 2.6.38.1 and traffic is 100Mb / s lspci:
> >> http://wklej.org/id/769102/ [2] /proc/cpuinfo:
> >> http://wklej.org/id/769104/ [3] /proc/interrupts:
> >> http://wklej.org/id/769106/ [4] ifconfig -a:
> >> http://wklej.org/id/769108/ [5] tc -s -d qdisc:
> >> http://wklej.org/id/769109/ [6] dmesg: here are some logs from=20
> >> iptables
> >> netstat -s: http://wklej.org/id/769110/ [7] lsmod:
> >> http://wklej.org/id/769117/ [8] /proc/net/softnet_stat:
> >> http://wklej.org/id/769116/ [9]
> >
> > Same infos of 3.5-rcX kernel would be nice.
> >
> > What NIC is eth0 ? (dmesg please)
> >
> > It seems all network traffic on 2.6.38 is handled by a single cpu=20
> > (cpu0)
> >
> > (seen in /proc/interrupts)
> >
> > I suspect that with 3.4 or 3.5 kernels, traffic is handled by many=20
> > cpus
> > and they hit false sharing and contention.
> >
> > You probably get better performance doing some affinity tuning :
> >
> > For example,
> > eth0 serviced by cpu0
> > eth2 serviced by cpu1
> > eth3 serviced by cpu2
> > eth5 serviced by cpu3
> >
> > and so on...
> >
> > check and/or set /proc/irq/${NUM}/smp_affinity
>=20
> hello
> I would go back to an earlier thread.
>=20
> Currently is installed kernel 3.6.0 and symptoms are the same
>=20
> about configuration:
>=20
> - affinity on
>=20
> - lspci: http://wklej.org/id/843156/ [10]
>=20
> - /proc/cpuinfo: http://wklej.org/id/843158/ [11]
>=20
> - /proc/interrupts: http://wklej.org/id/843161/ [12]
>=20
> - ifconfig -a: http://wklej.org/id/843162/ [13]
>=20
> - tc -s -d qdisc: http://wklej.org/id/843164/ [14]
>=20
> - dmesg: http://wklej.org/id/843166/ [15]
>=20
> - lsmod: http://wklej.org/id/843167/ [16]
>=20
> - /proc/net/softnet_stat: /proc/net/softnet_stat
>=20
> attach something else?
>=20
> Thanks

You should use RPS on eth2/eth3 because they are non multi queue.

Documentation/networking/scaling.txt should give you all the needed inf=
o
