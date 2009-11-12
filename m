From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Thu, 12 Nov 2009 08:52:50 +0000
Message-ID: <20091112085250.GA7112@ff.dom.local>
References: <412e6f7f0911111912q27f2b0aate56c637349292c3f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:60628 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbZKLIwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 03:52:55 -0500
Received: by bwz27 with SMTP id 27so1938327bwz.21
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 00:52:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911111912q27f2b0aate56c637349292c3f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-11-2009 04:12, Changli Gao wrote:
> On Wed, Nov 11, 2009 at 11:59 PM, Patrick McHardy <kaber@trash.net> wrote:
...
>> What protects the device from disappearing here and below during
>> dev_queue_xmit() and netif_rx_ni()?
> 
> For dev_queue_xmit(), dev is holded by skb->_dst, so there is no
> problem. But for netif_rx_ni(), I don't know how to prevent the device
> disappearing, and it seems that all the NIC drivers have this problem.
> Maybe there was the assumption about the execution context of
> netif_rx() before. Now softirq can't be executed by softirqd, so the
> packet receiving path maybe interleaved. I don't know how to prevent
> it happening.

Btw, maybe I miss something, but ifb with act_mirred is for many users
on the fast path. I'm not sure you proved enough why moving it to the
process context and additional multiqueue functionality (which seems
"pretty cool", but probably mostly for testing purposes) don't harm
its main use?

Regards,
Jarek P.
