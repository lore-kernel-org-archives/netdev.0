From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net 1/6] bnx2x: properly initialize statistic counters
Date: Tue, 16 Jul 2013 09:24:30 -0700
Message-ID: <1373991870.1949.3.camel@joe-AO722>
References: <1373988107-305-1-git-send-email-dmitry@broadcom.com>
	 <1373988107-305-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59487 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932821Ab3GPQYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 12:24:31 -0400
In-Reply-To: <1373988107-305-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 18:21 +0300, Dmitry Kravkov wrote:
> This prevent second statistics query be sent before first one is complete.
> This is required since two outstanding queries may cause FW assert.

Please run sparse on your code before submitting patches.

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
[]
> @@ -1591,10 +1591,16 @@ void bnx2x_stats_init(struct bnx2x *bp)
>  {
>  	int /*abs*/port = BP_PORT(bp);
>  	int mb_idx = BP_FW_MB_IDX(bp);
> +	__le16 init_fw_counter = le16_to_cpu(0xFFFF);

	__le16 init_fw_counter = cpu_to_le16(0xffff);

> +	struct stats_counter *counters = &bp->fw_stats_data->storm_counters;
>  
>  	bp->stats_pending = 0;
>  	bp->executer_idx = 0;
>  	bp->stats_counter = 0;
> +	counters->xstats_counter = init_fw_counter;
> +	counters->tstats_counter = init_fw_counter;
> +	counters->ustats_counter = init_fw_counter;
> +	counters->cstats_counter = init_fw_counter;

It might be better to remove init_fw_counter from
stack and use a #define or just use cpu_to_le16(0xffff)
in each init.
