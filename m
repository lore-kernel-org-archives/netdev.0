From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/9] mlx4: order-0 allocations and page recycling
Date: Mon,  6 Feb 2017 19:02:31 -0800
Message-ID: <20170207030240.31357-1-edumazet@google.com>
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
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35363 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751805AbdBGDDV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:03:21 -0500
Received: by mail-pg0-f50.google.com with SMTP id 194so34061311pgd.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 19:03:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As mentioned half a year ago, we better switch mlx4 driver to order-0
allocations and page recycling.

This reduces vulnerability surface thanks to better skb->truesize tracking
and provides better performance in most cases.

Worth noting this patch series deletes more than 100 lines of code ;)

Eric Dumazet (9):
  mlx4: use __skb_fill_page_desc()
  mlx4: dma_dir is a mlx4_en_priv attribute
  mlx4: remove order field from mlx4_en_frag_info
  mlx4: get rid of frag_prefix_size
  mlx4: rx_headroom is a per port attribute
  mlx4: reduce rx ring page_cache size
  mlx4: removal of frag_sizes[]
  mlx4: use order-0 pages for RX
  mlx4: add page recycling in receive path

 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 350 +++++++++------------------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  28 +--
 3 files changed, 129 insertions(+), 253 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
