From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] cxgb4: Add low latency socket busy_poll support
Date: Tue, 03 Feb 2015 21:58:29 -0800
Message-ID: <1423029509.907.79.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422940816-27402-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, praveenm@chelsio.com,
	kumaras@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:64584 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbbBDF6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 00:58:32 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so1781013igj.4
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 21:58:31 -0800 (PST)
In-Reply-To: <1422940816-27402-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-03 at 10:50 +0530, Hariprasad Shenai wrote:

> @@ -1978,9 +2016,13 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
>  {
>  	unsigned int params;
>  	struct sge_rspq *q = container_of(napi, struct sge_rspq, napi);
> -	int work_done = process_responses(q, budget);
> +	int work_done = 0;
>  	u32 val;
>  
> +	if (!cxgb_poll_lock_napi(q))
> +		return work_done;
> +


This is very suspicious. Please take a look at commits

24e579c8898aa641 ("bnx2x: fix napi poll return value for repoll") 
f104fedc0da126ab ("enic: fix rx napi poll return value")

for context.
