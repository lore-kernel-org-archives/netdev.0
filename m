From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3] ath10k: use dma_zalloc_coherent()
Date: Mon, 23 Jan 2017 15:19:29 -0800
Message-ID: <1485213569.12563.32.camel@perches.com>
References: <1485183876-27080-1-git-send-email-srinivas.kandagatla@linaro.org>
         <1485183876-27080-2-git-send-email-srinivas.kandagatla@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
        Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0138.hostedemail.com ([216.40.44.138]:52251 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750708AbdAWXTd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 18:19:33 -0500
In-Reply-To: <1485183876-27080-2-git-send-email-srinivas.kandagatla@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-23 at 15:04 +0000, Srinivas Kandagatla wrote:
> use dma_zalloc_coherent() instead of dma_alloc_coherent and memset().
[]
> diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
[]
> @@ -896,7 +896,7 @@ static int ath10k_pci_diag_read_mem(struct ath10k *ar, u32 address, void *data,
>  	 */
>  	alloc_nbytes = min_t(unsigned int, nbytes, DIAG_TRANSFER_LIMIT);
>  
> -	data_buf = (unsigned char *)dma_alloc_coherent(ar->dev,
> +	data_buf = (unsigned char *)dma_zalloc_coherent(ar->dev,
>  						       alloc_nbytes,
>  						       &ce_data_base,
>  						       GFP_ATOMIC);

trivia:

Nicer to realign arguments and remove the unnecessary cast.

Perhaps:

	data_buf = dma_zalloc_coherent(ar->dev, alloc_nbytes, &ce_data_base,
				       GFP_ATOMIC);
