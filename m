From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 03 Sep 2009 16:43:54 +0200
Message-ID: <4A9FD62A.3070605@gmail.com>
References: <20090902081429.GB4878@ff.dom.local> <4A9E2CC7.1010103@gmail.com> <alpine.DEB.1.10.0909021313160.27987@V090114053VZO-1> <Pine.LNX.4.64.0909031617060.28935@ask.diku.dk> <4A9FD2DC.7070807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Christoph Lameter <cl@linux-foundation.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57369 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506AbZICOoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 10:44:00 -0400
In-Reply-To: <4A9FD2DC.7070807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Jesper Dangaard Brouer wrote:
>> On Wed, 2 Sep 2009, Christoph Lameter wrote:
>>> On Wed, 2 Sep 2009, Eric Dumazet wrote:
>>>
>>>> Same name "eth0" is displayed, that might confuse parsers...
>>>>
>>>> What naming convention should we choose for multiqueue devices ?
>>> eth0/tx<number> ?
>> Remember that we already have a naming convention in /proc/interrupt=
s
>>
>>  eth0-tx-<number>
>>
>> Lets not introduce too many new once ;-)
>=20
> The approach I'm currently working on will present multiqueue root
> qdiscs as children of a dummy classful qdisc. This avoids handle
> clashes and the need for new identifiers and allows to address each
> qdisc seperately, similar to how it works with other classful qdiscs:
>=20
> qdisc mq 1: root refcnt 2
>  Sent 126 bytes 3 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
>=20
> class mq 1:1 root leaf 8001:
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq 1:2 root leaf 8002:
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq 1:3 root leaf 8003:
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq 1:4 root leaf 8004:
>  Sent 126 bytes 3 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
>=20
> Its a bit tricky though so I'm likely going to need a few more hours.

Seems pretty cool, thanks Patrick.
