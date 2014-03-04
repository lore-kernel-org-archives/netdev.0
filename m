From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv3 net-next 03/31] cxgb4: Rectify emitting messages about
 SGE Ingress DMA channels being potentially stuck
Date: Tue, 04 Mar 2014 09:43:55 -0800
Message-ID: <1393955035.20435.40.camel@joe-AO722>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
	 <1393936917-25847-4-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	davem@davemloft.net, roland@purestorage.com, kumaras@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0006.hostedemail.com ([216.40.44.6]:55912 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750990AbaCDRoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 12:44:01 -0500
In-Reply-To: <1393936917-25847-4-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-04 at 18:11 +0530, Hariprasad Shenai wrote:
> From: Kumar Sanghvi <kumaras@chelsio.com>
> 
> Based on original work by Casey Leedom <leedom@chelsio.com>

trivial comments:

> diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c

> @@ -2031,21 +2041,65 @@ static void sge_rx_timer_cb(unsigned long data)
[]
> +		if (idma_same_state_cnt[i] < s->idma_1s_thresh) {
> +			if (s->idma_stalled[i] >= SGE_IDMA_WARN_THRESH)
> +				CH_WARN(adap, "SGE idma%d, queue%u,resumed after %d sec",

Missing terminating '\n', probably better as:

				CH_WARN(adap, "SGE idma%d, queue%u, resumed after %d sec\n",

> +		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs"
> +			" (debug0=%#x, debug11=%#x)\n",

Probably better with the format coalesced:

		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs (debug0=%#x, debug11=%#x)\n",
