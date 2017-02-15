From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 02/13] net: ethernet: aquantia: Removed
 busy_count field.
Date: Wed, 15 Feb 2017 21:56:00 +0100
Message-ID: <ea723a97-cc0b-848f-8fda-d4fa93659b0f@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <d9dd4feb0cd2c9ecb3ea8bb66ff7e440ad53eef8.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:62122 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750791AbdBOU4L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:56:11 -0500
In-Reply-To: <d9dd4feb0cd2c9ecb3ea8bb66ff7e440ad53eef8.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2017 21:01, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
>
>  busy_count field and is_busy flag is not needed at all.
>
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c   | 11 -----------
>  drivers/net/ethernet/aquantia/atlantic/aq_utils.h |  1 -
>  2 files changed, 12 deletions(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index aa22a7c..a153750 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -122,14 +122,11 @@ static void aq_nic_service_timer_cb(unsigned long param)
>  	struct aq_nic_s *self = (struct aq_nic_s *)param;
>  	struct net_device *ndev = aq_nic_get_ndev(self);
>  	int err = 0;
> -	bool is_busy = false;
>  	unsigned int i = 0U;
>  	struct aq_hw_link_status_s link_status;
>  	struct aq_ring_stats_rx_s stats_rx;
>  	struct aq_ring_stats_tx_s stats_tx;
>
> -	atomic_inc(&self->header.busy_count);
> -	is_busy = true;
>  	if (aq_utils_obj_test(&self->header.flags, AQ_NIC_FLAGS_IS_NOT_READY))
>  		goto err_exit;
>
> @@ -170,8 +167,6 @@ static void aq_nic_service_timer_cb(unsigned long param)
>  	ndev->stats.tx_errors = stats_tx.errors;
>
>  err_exit:
> -	if (is_busy)
> -		atomic_dec(&self->header.busy_count);
>  	mod_timer(&self->service_timer,
>  		  jiffies + AQ_CFG_SERVICE_TIMER_INTERVAL);
>  }
> @@ -574,16 +569,12 @@ __acquires(&ring->lock)
>  	unsigned int trys = AQ_CFG_LOCK_TRYS;
>  	int err = 0;
>  	bool is_nic_in_bad_state;
> -	bool is_busy = false;
>  	struct aq_ring_buff_s buffers[AQ_CFG_SKB_FRAGS_MAX];
>
>  	frags = skb_shinfo(skb)->nr_frags + 1;
>
>  	ring = self->aq_ring_tx[AQ_NIC_TCVEC2RING(self, tc, vec)];
>
> -	atomic_inc(&self->header.busy_count);
> -	is_busy = true;
> -
>  	if (frags > AQ_CFG_SKB_FRAGS_MAX) {
>  		dev_kfree_skb_any(skb);
>  		goto err_exit;
> @@ -629,8 +620,6 @@ __acquires(&ring->lock)
>  	}
>
>  err_exit:
> -	if (is_busy)
> -		atomic_dec(&self->header.busy_count);
>  	return err;
>  }
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_utils.h b/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
> index 4446bd9..f6012b3 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
> @@ -19,7 +19,6 @@
>  struct aq_obj_s {
>  	spinlock_t lock; /* spinlock for nic/rings processing */
>  	atomic_t flags;
> -	atomic_t busy_count;
>  };
>
>  static inline void aq_utils_obj_set(atomic_t *flags, u32 mask)
>

Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Regards,
Lino
