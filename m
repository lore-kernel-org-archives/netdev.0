From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 v2] net: Add function to get SW rxhash
Date: Tue, 24 Sep 2013 14:30:03 -0700
Message-ID: <1380058203.3165.121.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309241335380.23856@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:65201 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab3IXVaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 17:30:05 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so5522960pad.19
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 14:30:04 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1309241335380.23856@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 13:42 -0700, Tom Herbert wrote:
> Some uses of skb_get_rxhash expect that the function will return
> a consistent value whether it is called on RX or TX paths. On RX
> path, we will use the rxhash if provided by the NIC, so this
> would not normally be the same result computed in TX path would be
> a software calculation.
> 
> This patch adds skb_get_sw_rxhash to explicitly request a hash
> calculated by the stack, disregarding the hash provided by NIC.

As I said, I think this is overhead in network fast path.

This can be done without adding a new skb field.

I suspect tun should not use rxhash but a proper hash, as conntrack or
tcp...
