From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 18/18] netvsc: call netif_receive_skb
Date: Tue, 24 Jan 2017 14:39:19 -0800
Message-ID: <1485297559.16328.343.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
         <20170124210615.18628-19-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kys@microsoft.com, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34104 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750856AbdAXWjW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 17:39:22 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so12883495pfb.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 14:39:21 -0800 (PST)
In-Reply-To: <20170124210615.18628-19-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-24 at 13:06 -0800, Stephen Hemminger wrote:
> To improve performance, netvsc can call network stack directly and
> avoid the local backlog queue. This is safe since incoming packets are
> handled in softirq context already because the receive function
> callback is called from a tasklet.

Is this tasklet implementing a limit or something ?

netif_rx() queues packets to the backlog, which is processed later by
net_rx_action() like other NAPI, with limit of 64 packets per round.

Calling netif_receive_skb() means you can escape this ability to fairly
distribute the cpu cycles among multiple NAPI.

I do not see range_cnt being capped in netvsc_receive()
