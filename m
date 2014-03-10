From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 net-next 08/31] iw_cxgb4: release neigh entry in
 error paths
Date: Mon, 10 Mar 2014 13:35:44 -0400 (EDT)
Message-ID: <20140310.133544.1092785181480653530.davem@davemloft.net>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
	<1394471308-4304-9-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbaCJRfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:35:48 -0400
In-Reply-To: <1394471308-4304-9-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon, 10 Mar 2014 22:38:05 +0530

> diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
> index 360807e..74a2250 100644
> --- a/drivers/infiniband/hw/cxgb4/cm.c
> +++ b/drivers/infiniband/hw/cxgb4/cm.c
> @@ -3350,10 +3350,9 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
>  	if (!e) {
>  		pr_err("%s - failed to allocate l2t entry!\n",
>  		       __func__);
> -		goto free_dst;
> +		goto free_neigh;
>  	}
>  
> -	neigh_release(neigh);
>  	step = dev->rdev.lldi.nrxq / dev->rdev.lldi.nchan;
>  	rss_qid = dev->rdev.lldi.rxq_ids[pi->port_id * step];
>  	window = (__force u16) htons((__force u16)tcph->window);
> @@ -3373,6 +3372,8 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
>  			      tcph->source, ntohl(tcph->seq), filter, window,
>  			      rss_qid, pi->port_id);
>  	cxgb4_l2t_release(e);
> +free_neigh:
> +	neigh_release(neigh);
>  free_dst:

It is so much easier to just move the existing neigh_release() call right
before the if(!e) test, that way you don't need a completely new label and
code block to fix this bug.
