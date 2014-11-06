From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] net: gro: add a per device gro flush timer
Date: Wed, 05 Nov 2014 17:38:35 -0800
Message-ID: <545AD11B.5050603@hp.com>
References: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:3618 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaKFBii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 20:38:38 -0500
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com [15.217.128.51])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 64A3DBAD
	for <netdev@vger.kernel.org>; Thu,  6 Nov 2014 01:38:38 +0000 (UTC)
In-Reply-To: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 04:55 PM, Eric Dumazet wrote:
> Tested:
>   Ran 200 netperf TCP_STREAM from A to B (10Gbe link, 8 RX queues)
>
> Without this feature, we send back about 305,000 ACK per second.
>
> GRO aggregation ratio is low (811/305 = 2.65 segments per GRO packet)
>
> Setting a timer of 2000 nsec is enough to increase GRO packet sizes
> and reduce number of ACK packets. (811/19.2 = 42)
>
> Receiver performs less calls to upper stacks, less wakes up.
> This also reduces cpu usage on the sender, as it receives less ACK
> packets.
>
> Note that reducing number of wakes up increases cpu efficiency, but can
> decrease QPS, as applications wont have the chance to warmup cpu caches
> doing a partial read of RPC requests/answers if they fit in one skb.

Speaking of QPS, what happens to 200 TCP_RR tests when the feature is 
enabled?

rick jones
