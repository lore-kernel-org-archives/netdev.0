From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu, 4 May 2017 18:48:12 +0200
Message-ID: <0babf800-080c-96e0-4dbb-8d3fca3fb784@gmx.de>
References: <90666578f043b366313ddd90ffad86de42d890f2.1493914743.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:50640 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752400AbdEDQsg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 12:48:36 -0400
In-Reply-To: <90666578f043b366313ddd90ffad86de42d890f2.1493914743.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pavel,

On 04.05.2017 18:33, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> This patch fixes the crash that happens when driver tries to collect statistics
> from already released "aq_vec" object.
> 
> Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index cdb0299..3a32573 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -755,7 +755,7 @@ void aq_nic_get_stats(struct aq_nic_s *self, u64 *data)
>  	count = 0U;
>  
>  	for (i = 0U, aq_vec = self->aq_vec[0];
> -		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
> +		aq_vec && self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
>  		data += count;
>  		aq_vec_get_sw_stats(aq_vec, data, &count);
>  	}
> @@ -961,6 +961,7 @@ void aq_nic_free_hot_resources(struct aq_nic_s *self)
>  	for (i = AQ_DIMOF(self->aq_vec); i--;) {
>  		if (self->aq_vec[i])
>  			aq_vec_free(self->aq_vec[i]);
> +			self->aq_vec[i] = NULL;
>  	}
>  
>  err_exit:;
> 

if the driver does not support statistics when the interface is down, would not it be clearer
to check if netif_running() in get_stats() instead?

Regards,
Lino
