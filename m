From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: Add low latency socket busy_poll support
Date: Wed, 4 Feb 2015 12:21:39 +0600
Message-ID: <20150204062137.GD30631@kumar-pc.asicdesigners.com>
References: <1422940816-27402-1-git-send-email-hariprasad@chelsio.com>
 <1423029509.907.79.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Hariprasad Shenai <hariprasad@chelsio.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<leedom@chelsio.com>, <anish@chelsio.com>, <nirranjan@chelsio.com>,
	<praveenm@chelsio.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23691 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbBDGvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 01:51:49 -0500
Content-Disposition: inline
In-Reply-To: <1423029509.907.79.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, February 02/03/15, 2015 at 21:58:29 -0800, Eric Dumazet wrote:
> On Tue, 2015-02-03 at 10:50 +0530, Hariprasad Shenai wrote:
> 
> > @@ -1978,9 +2016,13 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
> >  {
> >  	unsigned int params;
> >  	struct sge_rspq *q = container_of(napi, struct sge_rspq, napi);
> > -	int work_done = process_responses(q, budget);
> > +	int work_done = 0;
> >  	u32 val;
> >  
> > +	if (!cxgb_poll_lock_napi(q))
> > +		return work_done;
> > +
> 
> 
> This is very suspicious. Please take a look at commits
> 
> 24e579c8898aa641 ("bnx2x: fix napi poll return value for repoll") 
> f104fedc0da126ab ("enic: fix rx napi poll return value")
> 
> for context.

Thanks Eric for pointing on this.
So, this probably needs change after commit d75b1ade567ffab ("net: less interrupt masking in NAPI"), or
is there something else that is missed ?


Thanks,
Kumar.
