From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Mon, 28 Nov 2011 23:23:11 -0800
Message-ID: <4ED4885F.8060309@intel.com>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>  <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com> <1322550138.2970.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>, Tom Herbert <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17996 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751430Ab1K2HXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 02:23:12 -0500
In-Reply-To: <1322550138.2970.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2011 11:02 PM, Eric Dumazet wrote:
> Le mardi 29 novembre 2011 =C3=A0 05:23 +0100, Dave Taht a =C3=A9crit =
:
>>> In this test 100 netperf TCP_STREAMs were started to saturate the l=
ink.
>>> A single instance of a netperf TCP_RR was run with high priority se=
t.
>>> Queuing discipline in pfifo_fast, NIC is e1000 with TX ring size se=
t to
>>> 1024.  tps for the high priority RR is listed.
>>>
>>> No BQL, tso on: 3000-3200K bytes in queue: 36 tps
>>> BQL, tso on: 156-194K bytes in queue, 535 tps
>>
>>> No BQL, tso off: 453-454K bytes int queue, 234 tps
>>> BQL, tso off: 66K bytes in queue, 914 tps
>>
>>
>> Jeeze. Under what circumstances is tso a win? I've always
>> had great trouble with it, as some e1000 cards do it rather badly.
>>
>> I assume these are while running at GigE speeds?
>>
>> What of 100Mbit? 10GigE? (I will duplicate your tests
>> at 100Mbit, but as for 10gigE...)
>>
>=20
> TSO on means a low priority 65Kbytes packet can be in TX ring right
> before the high priority packet. If you cant afford the delay, you lo=
se.
>=20
> There is no mystery here.
>=20
> If you want low latencies :
> - TSO must be disabled so that packets are at most one ethernet frame=
=2E=20
> - You adjust BQL limit to small value
> - You even can lower MTU to get even more better latencies.
>=20
> If you want good throughput from your [10]GigE and low cpu cost, TSO
> should be enabled.
>=20
> If you want to be smart, you could have a dynamic behavior :
>=20
> Let TSO on as long as no high priority low latency producer is runnin=
g
> (if low latency packets are locally generated)
>=20
>=20

I wonder if we should consider enabling TSO/GSO per queue or per traffi=
c
class on devices that support this. At least in devices that support
multiple traffic classes it seems to be a common usage case to put bulk
storage traffic (iSCSI) on a traffic class and low latency traffic on a
separate traffic class, VoIP for example.

John.
