From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: RE: [PATCH net] bna: fix list corruption
Date: Fri, 26 Feb 2016 23:48:29 +0000
Message-ID: <2552F74A0BCCBE4DBE2AD218C81B2811086A6AB9@avmb3.qlogic.org>
References: <1456474550-16747-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Ivan Vecera <ivecera@redhat.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:1256 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754279AbcBZXsf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 18:48:35 -0500
In-Reply-To: <1456474550-16747-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Ivan Vecera [mailto:ivecera@redhat.com]
> Sent: Friday, February 26, 2016 12:16 AM
> 
> Use list_move_tail() to move MAC address entry from list of pending to list
> of active entries. Simple list_add_tail() leaves the entry also in the first list,
> this leads to list corruption.
> 
> Cc: Rasesh Mody <rasesh.mody@qlogic.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Rasesh Mody <rasesh.mody@qlogic.com>

> ---
>  drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
> b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
> index 04b0d16..95bc470 100644
> --- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
> +++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
> @@ -987,7 +987,7 @@ bna_rxf_ucast_cfg_apply(struct bna_rxf *rxf)
>  	if (!list_empty(&rxf->ucast_pending_add_q)) {
>  		mac = list_first_entry(&rxf->ucast_pending_add_q,
>  				       struct bna_mac, qe);
> -		list_add_tail(&mac->qe, &rxf->ucast_active_q);
> +		list_move_tail(&mac->qe, &rxf->ucast_active_q);
>  		bna_bfi_ucast_req(rxf, mac,
> BFI_ENET_H2I_MAC_UCAST_ADD_REQ);
>  		return 1;
>  	}
> --
> 2.4.10
