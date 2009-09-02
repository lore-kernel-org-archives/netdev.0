From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] tc: report informations for multiqueue devices
Date: Wed, 02 Sep 2009 15:49:59 +0200
Message-ID: <4A9E7807.2080901@gmail.com>
References: <20090902081429.GB4878@ff.dom.local>	<4A9E2CC7.1010103@gmail.com> <20090902.013002.181288977.davem@davemloft.net> <4A9E6551.4030209@gmail.com> <4A9E708D.5040806@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	cl@linux-foundation.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43777 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbZIBNuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 09:50:32 -0400
In-Reply-To: <4A9E708D.5040806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> [PATCH net-next-2.6] tc: report informations for multiqueue devices
>>
>> qdisc and classes are not yet displayed by "tc -s -d {qdisc|class} s=
how"
>> for multiqueue devices.
>>
>> We use a new TCA_QINDEX attribute, to report queue index to user spa=
ce.
>> iproute2 tc should be changed to eventually display this queue index=
 as in :
>>
>> $ tc -s -d qdisc
>> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1=
 1 1 1 1 1 1 1
>>  Sent 52498 bytes 465 pkt (dropped 0, overlimits 0 requeues 0)
>>  rate 0bit 0pps backlog 0b 0p requeues 0
>> qdisc pfifo_fast 0: dev eth0 qindex 1 root bands 3 priomap  1 2 2 2 =
1 2 0 0 1 1 1 1 1 1 1 1
>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>  rate 0bit 0pps backlog 0b 0p requeues 0
>=20
> This might confuse existing userspace since the handle is not unique
> anymore. libnl f.i. will treat all but the first root qdisc as an
> update and use it to update the state of the first one. There's also
> no combined view for applications unaware of multiqueue.
>=20
> Please have a look at the mail I just wrote for some possible ways
> around this.

Hum, how can we combine infos on qdisc/class if in the future we allow =
each queue index
to have its own qdisc/classes ?

htb on queue index 0
cbq on queue index 1

Combining info would lock us and not allow for special configurations.
Say=20
   macvlan device 0 mapped to queue index 0
   macvlan device 1 mapped to queue index 1...

=46or old apps, just give informations for queue 0 as we do now, and
allow kernel to give more informations only if new application provided=
 a TCA_INDEX attribute
in its request ?

(-1 : all queue indexes,  >=3D0 for a given queue index)
