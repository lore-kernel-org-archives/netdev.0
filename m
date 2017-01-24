From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] cxgbit: use T6 specific macro to set force bit
Date: Tue, 24 Jan 2017 13:11:40 -0800
Message-ID: <1485292300.12563.41.camel@perches.com>
References: <1485257822-729-1-git-send-email-varun@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
        indranil@chelsio.com
To: Varun Prakash <varun@chelsio.com>, bart.vanassche@sandisk.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0239.hostedemail.com ([216.40.44.239]:34166 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750969AbdAXVLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:11:45 -0500
In-Reply-To: <1485257822-729-1-git-send-email-varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-24 at 17:07 +0530, Varun Prakash wrote:
> For T6 adapters use T6 specific macro to set
> force bit.
[]
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
[]
> @@ -1349,6 +1349,10 @@ struct cpl_tx_data {
>  #define TX_FORCE_S	13
>  #define TX_FORCE_V(x)	((x) << TX_FORCE_S)
>  
> +#define T6_TX_FORCE_S		20
> +#define T6_TX_FORCE_V(x)	((x) << T6_TX_FORCE_S)
> +#define T6_TX_FORCE_F		T6_TX_FORCE_V(1U)
> +
>  enum {
>  	ULP_TX_MEM_READ = 2,
>  	ULP_TX_MEM_WRITE = 3,
> diff --git a/drivers/target/iscsi/cxgbit/cxgbit_target.c b/drivers/target/iscsi/cxgbit/cxgbit_target.c
[]
> @@ -162,12 +162,14 @@ cxgbit_tx_data_wr(struct cxgbit_sock *csk, struct sk_buff *skb, u32 dlen,
>  		  u32 len, u32 credits, u32 compl)
>  {
>  	struct fw_ofld_tx_data_wr *req;
> +	const struct cxgb4_lld_info *lldi = &csk->com.cdev->lldi;
>  	u32 submode = cxgbit_skcb_submode(skb);
>  	u32 wr_ulp_mode = 0;
>  	u32 hdr_size = sizeof(*req);
>  	u32 opcode = FW_OFLD_TX_DATA_WR;
>  	u32 immlen = 0;
> -	u32 force = TX_FORCE_V(!submode);
> +	u32 force = is_t5(lldi->adapter_type) ? TX_FORCE_V(!submode) :
> +		    T6_TX_FORCE_F;

Perhaps it'd be better to add a is_t6() mechanism so this
is written in the positive rather than the negative.
