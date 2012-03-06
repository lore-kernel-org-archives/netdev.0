From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH net-next] net: export netdev_stats_to_stats64
Date: Tue, 6 Mar 2012 12:38:50 +0800
Message-ID: <CABoNC82c2G+2ubS8it+dAdQBK3EvyaArdGxhZh-KY=3YraMdNA@mail.gmail.com>
References: <20120305113353.GA12969@Spy32>
	<1330954326.2474.9.camel@edumazet-laptop>
	<1330955921.2474.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:55582 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757943Ab2CFEiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 23:38:51 -0500
Received: by vcqp1 with SMTP id p1so4087316vcq.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 20:38:50 -0800 (PST)
In-Reply-To: <1330955921.2474.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Some drivers use internal netdev stats member to store part of their
> stats, yet advertize ndo_get_stats64() to implement some 64bit fields.
>
> Allow them to use netdev_stats_to_stats64() helper to make the copy of
> netdev stats before they compute their 64bit counters.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Hi Eric,
And I think we can add a netdev_stats_add_to_stats64() helper to avoid
following duplicate code. Is that acceptable? Thanks.

drivers/net/bonding/bond_main.c
                stats->rx_packets += sstats->rx_packets;
                stats->rx_bytes += sstats->rx_bytes;
                stats->rx_errors += sstats->rx_errors;
                stats->rx_dropped += sstats->rx_dropped;

                stats->tx_packets += sstats->tx_packets;
                stats->tx_bytes += sstats->tx_bytes;
                stats->tx_errors += sstats->tx_errors;
                stats->tx_dropped += sstats->tx_dropped;

                stats->multicast += sstats->multicast;
                stats->collisions += sstats->collisions;

                stats->rx_length_errors += sstats->rx_length_errors;
                stats->rx_over_errors += sstats->rx_over_errors;
                stats->rx_crc_errors += sstats->rx_crc_errors;
                stats->rx_frame_errors += sstats->rx_frame_errors;
                stats->rx_fifo_errors += sstats->rx_fifo_errors;
                stats->rx_missed_errors += sstats->rx_missed_errors;

                stats->tx_aborted_errors += sstats->tx_aborted_errors;
                stats->tx_carrier_errors += sstats->tx_carrier_errors;
                stats->tx_fifo_errors += sstats->tx_fifo_errors;
                stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
                stats->tx_window_errors += sstats->tx_window_errors;

-- 
--Junchang
