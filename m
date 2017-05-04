From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu, 04 May 2017 13:30:03 -0700
Message-ID: <1493929803.31950.3.camel@perches.com>
References: <9ea5a2ba21b4f8b22a63acf39135a41e2f1da23c.1493928470.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0093.hostedemail.com ([216.40.44.93]:33677 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751702AbdEDUaM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 16:30:12 -0400
In-Reply-To: <9ea5a2ba21b4f8b22a63acf39135a41e2f1da23c.1493928470.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-05-04 at 23:10 +0300, Pavel Belous wrote:
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
[]
> @@ -959,8 +959,10 @@ void aq_nic_free_hot_resources(struct aq_nic_s *self)
>  		goto err_exit;
>  
>  	for (i = AQ_DIMOF(self->aq_vec); i--;) {
> -		if (self->aq_vec[i])
> +		if (self->aq_vec[i]) {
>  			aq_vec_free(self->aq_vec[i]);
> +			self->aq_vec[i] = NULL;
> +		}
>  	}
>  
>  err_exit:;

unrelated style trivia:

err_exit:;

the error label then :; is pretty odd.

Also casting the return value to void is really odd.
A simple return instead of goto would be more common.

drivers/net/ethernet/aquantia/atlantic/aq_ring.c:311:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_ring.c:326:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_main.c:161:err_exit:;
drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c:277:err_exit:;
drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c:313:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_nic.c:304:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_nic.c:763:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_nic.c:951:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_nic.c:966:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_vec.c:281:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_vec.c:302:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c:251:err_exit:;
drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c:270:err_exit:;
