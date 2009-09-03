From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 03 Sep 2009 16:29:48 +0200
Message-ID: <4A9FD2DC.7070807@trash.net>
References: <20090902081429.GB4878@ff.dom.local> <4A9E2CC7.1010103@gmail.com> <alpine.DEB.1.10.0909021313160.27987@V090114053VZO-1> <Pine.LNX.4.64.0909031617060.28935@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40594 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595AbZICO3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 10:29:50 -0400
In-Reply-To: <Pine.LNX.4.64.0909031617060.28935@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> 
> On Wed, 2 Sep 2009, Christoph Lameter wrote:
>> On Wed, 2 Sep 2009, Eric Dumazet wrote:
>>
>>> Same name "eth0" is displayed, that might confuse parsers...
>>>
>>> What naming convention should we choose for multiqueue devices ?
>>
>> eth0/tx<number> ?
> 
> Remember that we already have a naming convention in /proc/interrupts
> 
>  eth0-tx-<number>
> 
> Lets not introduce too many new once ;-)

The approach I'm currently working on will present multiqueue root
qdiscs as children of a dummy classful qdisc. This avoids handle
clashes and the need for new identifiers and allows to address each
qdisc seperately, similar to how it works with other classful qdiscs:

qdisc mq 1: root refcnt 2
 Sent 126 bytes 3 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

class mq 1:1 root leaf 8001:
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
class mq 1:2 root leaf 8002:
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
class mq 1:3 root leaf 8003:
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
class mq 1:4 root leaf 8004:
 Sent 126 bytes 3 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

Its a bit tricky though so I'm likely going to need a few more hours.
