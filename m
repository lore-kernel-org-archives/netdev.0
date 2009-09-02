From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 02 Sep 2009 10:28:55 +0200
Message-ID: <4A9E2CC7.1010103@gmail.com>
References: <20090902081429.GB4878@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42886 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102AbZIBI3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 04:29:00 -0400
In-Reply-To: <20090902081429.GB4878@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> [Resent with fixed netdev@ address]
>=20
> On 02-09-2009 01:52, Christoph Lameter wrote:
>> [NET] Add proc file to display the state of all qdiscs
>>
>> TC is a complicated tool and it currently does not allow the display=
 of all
>> qdisc states. It does not support multiple tx queues and also not
>> localhost, nor does it display the current operating state of the qu=
eues.
>=20
> I think, tc should've no problem with displaying summary stats of
> multiqueue qdiscs or even all of them separately, as mentioned by
> Patrick. And, maybe I still miss something, but there should be
> nothing special with tc vs. localhost either.
>

I made a patch, but for a 8 queue device (bnx2), here is the "tc -s -d =
qdisc" result :

$ tc -s -d qdisc show
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 51814 bytes 459 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0


Same name "eth0" is displayed, that might confuse parsers...

What naming convention should we choose for multiqueue devices ?

