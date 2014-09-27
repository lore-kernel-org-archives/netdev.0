From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] net: pktgen: packet bursting via
 skb->xmit_more
Date: Sat, 27 Sep 2014 13:43:10 -0700
Message-ID: <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
	 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34547 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaI0UnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 16:43:13 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so4642386pad.15
        for <netdev@vger.kernel.org>; Sat, 27 Sep 2014 13:43:12 -0700 (PDT)
In-Reply-To: <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-26 at 00:42 -0700, Eric Dumazet wrote:

> By the way with this patch, I now reach 10 Mpps on mlx4 
> 
> base line : 5 Mpps
> 
> + skb->xmit_more and quick hack in pjtgen (spinlock/unlock per packet)
> -> 7 Mpps
> 
> + burst of 16 packets, no spinlock per packet -> 10 Mpps

With careful study of mlx4 driver to remove false sharing, I now get 14
Mpps.

(Note they have a special feature to 'inline' small packets in tx
descriptors : If this is used, max rate is lower, because cpu spend more
cycles to perform the copies)

I find worrying driver authors do not know how to properly use a ring
buffer, and do not place the producer and consumer indexes in separate
cache lines.
