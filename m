From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce netdevice gso_min_segs attribute
Date: Mon, 06 Oct 2014 14:42:58 -0700
Message-ID: <1412631778.11091.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54312F50.2060608@mellanox.com>
	 <1412524252.11091.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141006.172149.1596496098013953331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, edumazet@google.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com, idos@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:42111 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbaJFVm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:42:59 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so3963473pdb.3
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 14:42:59 -0700 (PDT)
In-Reply-To: <20141006.172149.1596496098013953331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 17:21 -0400, David Miller wrote:

> So exactly what value are you using for mlx4?
> 

It seems that on ConnectX-3 family, TSO packets of 2 or 3 MSS are not
worth using TSO engine. The cutoff point seems to be 4 (same throughput)

So I was planning to use gso_min_segs = 4 only for them.

> Because I wonder if we should just generically forfeit TSO unless
> we have > 2 segments, for example.

When I tested on bnx2x, this was not a gain.

bnx2x is faster sending TSO packets, even if they have 2 MSS.

I'll try the experiment on I40E Intel cards.
