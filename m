From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally
 send doorbell
Date: Thu, 25 Sep 2014 08:06:55 -0700
Message-ID: <1411657615.16953.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140925164333.7cba128a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35027 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828AbaIYPG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 11:06:56 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so2718791pad.28
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 08:06:56 -0700 (PDT)
In-Reply-To: <20140925164333.7cba128a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 16:43 +0200, Jesper Dangaard Brouer wrote:
> On Thu, 25 Sep 2014 07:17:49 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Tested with a modified pktgen version, I got a 40% increase of
> > throughput.
> 
> Pktgen is artificial benchmarking, you know ;-) :-P
> 
> If you really must use pktgen for this, you can use an unmodified
> pktgen against the qdisc layer by adding a VLAN interface on-top of the
> device you want to test.  I blame John, for telling me this ;-)
> 
> /me running away


But... Nothing yet in qdisc layer sets xmit_more, unless TSO is
disabled, and a GSO packet is segmented.

So you might notice some improvement with this patch, but not if you use
TSO, and a 40GB NIC is better with TSO on you know ;)
