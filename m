From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH net-next V2 3/3] net/mlx4_en: Add ethtool statistics for
 XDP cases
Date: Tue, 1 Nov 2016 15:06:04 -0600
Message-ID: <20161101210604.GA29427@gmail.com>
References: <1478000186-5158-1-git-send-email-tariqt@mellanox.com>
 <1478000186-5158-4-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35504 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932493AbcKAVGK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 17:06:10 -0400
Received: by mail-pf0-f181.google.com with SMTP id i88so7532883pfk.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 14:06:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1478000186-5158-4-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 01, 2016 at 01:36:26PM +0200, Tariq Toukan wrote:
> XDP statistics are reported in ethtool as follows:
> - xdp_drop: the number of packets dropped by xdp.
> - xdp_tx: the number of packets forwarded by xdp.
> - xdp_tx_full: the number of times an xdp forward failed
> 	due to a full tx xdp ring.
> 
> In addition, all packets that are dropped/forwarded by XDP
> are no longer accounted in rx_packets/rx_bytes of the ring,
> so that they count traffic that is passed to the stack.
This seems like a step backwards, in that I now no longer have any
statistic whatsoever that can count xdp packets per-ring. For instance,
how would I validate that my flow-hash rules are operating correctly? I
would suggest to restore the rxN_packet/bytes stat increment.
> 
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 14 ++++++++++++++
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  4 ++++
>  drivers/net/ethernet/mellanox/mlx4/en_port.c    |  6 ++++++
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 12 +++++++-----
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c      |  8 ++++----
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  7 ++++++-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h | 10 +++++++++-
>  7 files changed, 50 insertions(+), 11 deletions(-)
[...]
