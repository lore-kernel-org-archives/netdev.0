From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next RFC 1/2] tun: enable NAPI for TUN/TAP driver
Date: Tue, 5 Sep 2017 15:51:27 -0700
Message-ID: <20170905155127.0bd08fb0@xeon-e3>
References: <20170905223551.27925-1-ppenkov@google.com>
        <20170905223551.27925-2-ppenkov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Willem de Bruijn <willemb@google.com>, davem@davemloft.net,
        ppenkov@stanford.edu
To: Petar Penkov <ppenkov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33639 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752962AbdIEWvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 18:51:35 -0400
Received: by mail-pg0-f45.google.com with SMTP id t3so12027344pgt.0
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 15:51:35 -0700 (PDT)
In-Reply-To: <20170905223551.27925-2-ppenkov@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Sep 2017 15:35:50 -0700
Petar Penkov <ppenkov@google.com> wrote:

> Changes TUN driver to use napi_gro_receive() upon receiving packets
> rather than netif_rx_ni(). Adds flag CONFIG_TUN_NAPI that enables
> these changes and operation is not affected if the flag is disabled.
> SKBs are constructed upon packet arrival and are queued to be
> processed later.
> 
> The new path was evaluated with a benchmark with the following setup:
> Open two tap devices and a receiver thread that reads in a loop for
> each device. Start one sender thread and pin all threads to different
> CPUs. Send 1M minimum UDP packets to each device and measure sending
> time for each of the sending methods:
> 	napi_gro_receive(): 	4.90s
> 	netif_rx_ni(): 		4.90s
> 	netif_receive_skb(): 	7.20s
> 
> Signed-off-by: Petar Penkov <ppenkov@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: davem@davemloft.net
> Cc: ppenkov@stanford.edu

Why is this optional? It adds two code paths both of which need
to be tested.
