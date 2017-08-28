From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Fix some u16 fields appropriately
Date: Mon, 28 Aug 2017 16:19:24 -0700 (PDT)
Message-ID: <20170828.161924.1286298670313299855.davem@davemloft.net>
References: <1503818685-32068-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503818685-32068-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sun, 27 Aug 2017 15:24:45 +0800

> In be_tx_compl_process, frag_index declared as u32, so it's better to
> declare last_index as u32 also.
> 
> CC: Ajit Khaparde <ajit.khaparde@broadcom.com>
> Fixes: b0fd2eb28bd4 ("be2net: Declare some u16 fields as u32 to improve
> performance")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

That is not a legitimate reason for making this change.

> @@ -255,7 +255,7 @@ struct be_tx_stats {
>  /* Structure to hold some data of interest obtained from a TX CQE */
>  struct be_tx_compl_info {
>  	u8 status;		/* Completion status */
> -	u16 end_index;		/* Completed TXQ Index */
> +	u32 end_index;		/* Completed TXQ Index */
>  };
>  
>  struct be_tx_obj {

The ->end_index comes solely from:

	txcp->end_index = GET_TX_COMPL_BITS(wrb_index, compl);

Which is precisely a 16-bit value.

I'm not applying this, sorry.
