From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 00/14] mlx4: order-0 allocations and page recycling
Date: Thu,  9 Feb 2017 05:58:24 -0800
Message-ID: <20170209135838.16487-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34823 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752487AbdBIN6n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:58:43 -0500
Received: by mail-pg0-f53.google.com with SMTP id 194so1081469pgd.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:58:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As mentioned half a year ago, we better switch mlx4 driver to order-0
allocations and page recycling.

This reduces vulnerability surface thanks to better skb->truesize
tracking and provides better performance in most cases.

v2 provides an ethtool -S new counter (rx_alloc_pages) and
code factorization, plus Tariq fix.

Worth noting this patch series deletes ~250 lines of code ;)

Eric Dumazet (14):
  mlx4: use __skb_fill_page_desc()
  mlx4: dma_dir is a mlx4_en_priv attribute
  mlx4: remove order field from mlx4_en_frag_info
  mlx4: get rid of frag_prefix_size
  mlx4: rx_headroom is a per port attribute
  mlx4: reduce rx ring page_cache size
  mlx4: removal of frag_sizes[]
  mlx4: use order-0 pages for RX
  mlx4: add page recycling in receive path
  mlx4: add rx_alloc_pages counter in ethtool -S
  mlx4: do not access rx_desc from mlx4_en_process_rx_cq()
  mlx4: factorize page_address() calls
  mlx4: make validate_loopback() more generic
  mlx4: remove duplicate code in mlx4_en_process_rx_cq()

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.c     |   2 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       | 597 +++++++----------------
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |   6 -
 drivers/net/ethernet/mellanox/mlx4/en_tx.c       |   4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     |  29 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h  |   2 +-
 7 files changed, 195 insertions(+), 447 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
