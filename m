From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 0/3] net: bulk free adjustment and two driver
 use-cases
Date: Thu, 10 Mar 2016 13:15:18 +0100
Message-ID: <20160310121414.3680.45727.stgit@firesoul>
References: <CAKgT0Uey2fgDj3-7sitLofLP3UwD+=Su_5tSxi7T8FngE_CptQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	gerlitz.or@gmail.com
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798AbcCJMP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 07:15:26 -0500
In-Reply-To: <CAKgT0Uey2fgDj3-7sitLofLP3UwD+=Su_5tSxi7T8FngE_CptQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've split out the bulk free adjustments, from the bulk alloc patches,
as I want the adjustment to napi_consume_skb to be in same kernel cycle
the API was introduced.

Adjustments based on discussion:
 Subj: "mlx4: use napi_consume_skb API to get bulk free operations"
 http://thread.gmane.org/gmane.linux.network/402503/focus=403386

Patchset based on net-next at commit 3ebeac1d0295

---

Jesper Dangaard Brouer (3):
      net: adjust napi_consume_skb to handle none-NAPI callers
      mlx4: use napi_consume_skb API to get bulk free operations
      mlx5: use napi_consume_skb API to get bulk free operations


 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   16 ++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    2 +-
 net/core/skbuff.c                                 |    4 ++--
 5 files changed, 16 insertions(+), 12 deletions(-)
