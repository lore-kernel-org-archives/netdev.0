From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/softnet_stat & NAPI
Date: Tue, 20 Nov 2012 10:25:43 -0800
Message-ID: <1353435943.2590.25.camel@edumazet-glaptop>
References: <CAB15j_Dv8hQCDzAYxkTGs5yjz5uhETuhgRxfAvbVbt5mx-P33A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Schipp <jonschipp@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:39138 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab2KTSZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 13:25:46 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1348006dak.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 10:25:46 -0800 (PST)
In-Reply-To: <CAB15j_Dv8hQCDzAYxkTGs5yjz5uhETuhgRxfAvbVbt5mx-P33A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-20 at 13:06 -0500, Jon Schipp wrote:
> In relation to packet drops, assuming a new kernel, NAPI driver, and
> no use of receive packet steering,
> does /proc/net/softnet_stats provide any useful packet drop information?
> 

no

> I know that on earlier 2.4 kernels one could grab the drops in the
> backlog queue from 2nd column in /proc/net/softnet_stats.
> In a modern systems that use NAPI, does softnet_stats serve a similar
> purpose e.g. display drops in a NAPI poll queue?

Second column is number of dropped packets because
one (percpu) queue reached netdev_max_backlog

But its only in the case packet must be queued in the first place.

With a NAPI driver and no RPS/RFS, packets wont be dropped here, as NAPI
netif_receive_skb() directly calls the network stack.

If frames are dropped, they should be dropped by the NIC itself.

Even with 2.4 kernels or non NAPI driver, you could have drops at NIC
level.
