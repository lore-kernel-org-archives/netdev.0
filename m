From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Netperf TCP_RR(loopback) 10%
	regression	in	2.6.24-rc6,	comparing with 2.6.22
Date: Tue, 22 Jan 2008 14:52:32 +0800
Message-ID: <1200984752.3151.261.camel@ymzhang>
References: <1199871330.3298.132.camel@ymzhang>
	 <1200043854.3265.24.camel@ymzhang>  <4787ADDA.7090602@hp.com>
	 <1200280292.3151.24.camel@ymzhang>  <478B9FE0.3040801@hp.com>
	 <1200979482.3151.103.camel@ymzhang> <1200982039.3151.120.camel@ymzhang>
	 <47958CC8.9060609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:62303 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751574AbYAVGx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 01:53:57 -0500
In-Reply-To: <47958CC8.9060609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-01-22 at 07:27 +0100, Eric Dumazet wrote:
> Zhang, Yanmin a =E9crit :
> > On Tue, 2008-01-22 at 13:24 +0800, Zhang, Yanmin wrote:
> >> On Mon, 2008-01-14 at 09:46 -0800, Rick Jones wrote:
> >>>>> *) netperf/netserver support CPU affinity within themselves wit=
h the=20
> >>>>> global -T option to netperf.  Is the result with taskset much d=
ifferent?=20
> >>>>>   The equivalent to the above would be to run netperf with:
> >>>>>
> >>>>> ./netperf -T 0,7 ..
> >>>> I checked the source codes and didn't find this option.
> >>>> I use netperf V2.3 (I found the number in the makefile).
> >>> Indeed, that version pre-dates the -T option.  If you weren't alr=
eady=20
> >>> chasing a regression I'd suggest an upgrade to 2.4.mumble.  Once =
you are=20
> >>> at a point where changing another variable won't muddle things yo=
u may=20
> >>> want to consider upgrading.
> >>>
> >>> happy benchmarking,
> >> Rick,
> >>
> >> I found my UDP_RR testing is just loop in netperf instead of ping-=
pang between
> >> netserver and netperf. Is it correct? TCP_RR is ok.
> >>
> >> #./netserver
> >> #./netperf -t UDP_RR -l 60 -H 127.0.0.1 -i 30,3 -I 99,5 -- -P 1238=
4 -r 1,1
> > I digged into netperf and netserver.
> >=20
> > netperf binds ip 0 and port 12384 to its own socket. netserver bind=
s ip
> > 127.0.0.1 and port 12384 to its own socket. Then, netperf calls con=
nect to setup server
> > 127.0.0.1 and port 12384. Then, netperf starts sends UDP packets, b=
ut all packets netperf
> > sends are just received by netperf itself. netserver doesn't receiv=
e any packet.
> >=20
> > I think netperf binding should fail, or netperf shouldn't get the p=
acket it sends out, because
> > netserver already binds port 12384.
> >=20
> > I am wondering if UDP stack in kernel has a bug.
>=20
> If :
> - socket A is bound to 0.0.0.0:12384 and
> - socket B is bound to 127.0.0.1:12384
>=20
> Then packets sent to 127.0.0.1:12384 should be queued for socket B
>=20
> If they are queued to socket A as you believe it is currently done, t=
hen yes=20
> there is a bug in kernel.
I double-checked it and they are queued to socket A. If I define a diff=
erent local port
for netperf, packets will be queued to socket B.

-yanmin


