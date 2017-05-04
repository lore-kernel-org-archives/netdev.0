From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu, 4 May 2017 21:41:28 +0300
Message-ID: <69bfcc3a-f955-83f1-7acc-4841500568fe@aquantia.com>
References: <90666578f043b366313ddd90ffad86de42d890f2.1493914743.git.pavel.belous@aquantia.com>
 <50047294-4f40-e8ae-0982-5720b87019a9@redhat.com>
 <800da97f-7a4b-6f61-f4ff-51d4ef50e05f@aquantia.com>
 <1493921851.22125.42.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, David Arcari <darcari@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0053.outbound.protection.outlook.com ([104.47.38.53]:37440
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752337AbdEDSlq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 14:41:46 -0400
In-Reply-To: <1493921851.22125.42.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04.05.2017 21:17, Joe Perches wrote:
> On Thu, 2017-05-04 at 20:08 +0300, Pavel Belous wrote:
>> I will prepare another patch with Lino and David M. comments.
>
> I'm not submitting this because it'd just cause merge conflicts,
> but
> something you could do one day is remove the AQ_DIMOF macro
> and just use ARRAY_SIZE directly.
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c              | 4 ++--
>  drivers/net/ethernet/aquantia/atlantic/aq_utils.h            | 2 --
>  drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c    | 2 +-
>  drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c    | 2 +-
>  drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c | 2 +-
>  5 files changed, 5 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index cdb02991f249..cffae53414ba 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -154,7 +154,7 @@ static void aq_nic_service_timer_cb(unsigned long param)
>
>  	memset(&stats_rx, 0U, sizeof(struct aq_ring_stats_rx_s));
>  	memset(&stats_tx, 0U, sizeof(struct aq_ring_stats_tx_s));
> -	for (i = AQ_DIMOF(self->aq_vec); i--;) {
> +	for (i = ARRAY_SIZE(self->aq_vec); i--;) {
>  		if (self->aq_vec[i])
>  			aq_vec_add_stats(self->aq_vec[i], &stats_rx, &stats_tx);
>  	}
> @@ -958,7 +958,7 @@ void aq_nic_free_hot_resources(struct aq_nic_s *self)
>  	if (!self)
>  		goto err_exit;
>
> -	for (i = AQ_DIMOF(self->aq_vec); i--;) {
> +	for (i = ARRAY_SIZE(self->aq_vec); i--;) {
>  		if (self->aq_vec[i])
>  			aq_vec_free(self->aq_vec[i]);
>  	}
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_utils.h b/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
> index f6012b34abe6..64a8c3c781ff 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
> @@ -14,8 +14,6 @@
>
>  #include "aq_common.h"
>
> -#define AQ_DIMOF(_ARY_)  ARRAY_SIZE(_ARY_)
> -
>  struct aq_obj_s {
>  	spinlock_t lock; /* spinlock for nic/rings processing */
>  	atomic_t flags;
> diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
> index 4ee15ff06a44..96c3360e7060 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
> @@ -182,7 +182,7 @@ static int hw_atl_a0_hw_rss_set(struct aq_hw_s *self,
>  			((i * 3U) & 0xFU));
>  	}
>
> -	for (i = AQ_DIMOF(bitary); i--;) {
> +	for (i = ARRAY_SIZE(bitary); i--;) {
>  		rpf_rss_redir_tbl_wr_data_set(self, bitary[i]);
>  		rpf_rss_redir_tbl_addr_set(self, i);
>  		rpf_rss_redir_wr_en_set(self, 1U);
> diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
> index 42150708191d..5a19eba31786 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
> @@ -182,7 +182,7 @@ static int hw_atl_b0_hw_rss_set(struct aq_hw_s *self,
>  			((i * 3U) & 0xFU));
>  	}
>
> -	for (i = AQ_DIMOF(bitary); i--;) {
> +	for (i = ARRAY_SIZE(bitary); i--;) {
>  		rpf_rss_redir_tbl_wr_data_set(self, bitary[i]);
>  		rpf_rss_redir_tbl_addr_set(self, i);
>  		rpf_rss_redir_wr_en_set(self, 1U);
> diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
> index 8d6d8f5804da..922af5f36d37 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
> @@ -385,7 +385,7 @@ int hw_atl_utils_get_mac_permanent(struct aq_hw_s *self,
>  					    aq_hw_read_reg(self, 0x00000374U) +
>  					    (40U * 4U),
>  					    mac_addr,
> -					    AQ_DIMOF(mac_addr));
> +					    ARRAY_SIZE(mac_addr));
>  	if (err < 0) {
>  		mac_addr[0] = 0U;
>  		mac_addr[1] = 0U;
>

Thank you,
I will do it, little bit later.

Regards,
Pavel
