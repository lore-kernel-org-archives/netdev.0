From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression	in	2.6.24-rc6,	comparing
 with 2.6.22
Date: Tue, 22 Jan 2008 07:27:20 +0100
Message-ID: <47958CC8.9060609@cosmosbay.com>
References: <1199871330.3298.132.camel@ymzhang>	 <1200043854.3265.24.camel@ymzhang>  <4787ADDA.7090602@hp.com>	 <1200280292.3151.24.camel@ymzhang>  <478B9FE0.3040801@hp.com>	 <1200979482.3151.103.camel@ymzhang> <1200982039.3151.120.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:60153
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751015AbYAVG13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 01:27:29 -0500
In-Reply-To: <1200982039.3151.120.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhang, Yanmin a =C3=A9crit :
> On Tue, 2008-01-22 at 13:24 +0800, Zhang, Yanmin wrote:
>> On Mon, 2008-01-14 at 09:46 -0800, Rick Jones wrote:
>>>>> *) netperf/netserver support CPU affinity within themselves with =
the=20
>>>>> global -T option to netperf.  Is the result with taskset much dif=
ferent?=20
>>>>>   The equivalent to the above would be to run netperf with:
>>>>>
>>>>> ./netperf -T 0,7 ..
>>>> I checked the source codes and didn't find this option.
>>>> I use netperf V2.3 (I found the number in the makefile).
>>> Indeed, that version pre-dates the -T option.  If you weren't alrea=
dy=20
>>> chasing a regression I'd suggest an upgrade to 2.4.mumble.  Once yo=
u are=20
>>> at a point where changing another variable won't muddle things you =
may=20
>>> want to consider upgrading.
>>>
>>> happy benchmarking,
>> Rick,
>>
>> I found my UDP_RR testing is just loop in netperf instead of ping-pa=
ng between
>> netserver and netperf. Is it correct? TCP_RR is ok.
>>
>> #./netserver
>> #./netperf -t UDP_RR -l 60 -H 127.0.0.1 -i 30,3 -I 99,5 -- -P 12384 =
-r 1,1
> I digged into netperf and netserver.
>=20
> netperf binds ip 0 and port 12384 to its own socket. netserver binds =
ip
> 127.0.0.1 and port 12384 to its own socket. Then, netperf calls conne=
ct to setup server
> 127.0.0.1 and port 12384. Then, netperf starts sends UDP packets, but=
 all packets netperf
> sends are just received by netperf itself. netserver doesn't receive =
any packet.
>=20
> I think netperf binding should fail, or netperf shouldn't get the pac=
ket it sends out, because
> netserver already binds port 12384.
>=20
> I am wondering if UDP stack in kernel has a bug.

If :
- socket A is bound to 0.0.0.0:12384 and
- socket B is bound to 127.0.0.1:12384

Then packets sent to 127.0.0.1:12384 should be queued for socket B

If they are queued to socket A as you believe it is currently done, the=
n yes=20
there is a bug in kernel.

>=20
> TCP_RR testing hasn't such issue.
>=20
> -yanmin
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

