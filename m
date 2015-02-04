From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] cxgb4: Add low latency socket busy_poll support
Date: Tue, 03 Feb 2015 23:50:50 -0800
Message-ID: <1423036250.907.101.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422940816-27402-1-git-send-email-hariprasad@chelsio.com>
	 <1423029509.907.79.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150204062137.GD30631@kumar-pc.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org,
	davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com
To: Kumar Sanghvi <kumaras@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:41175 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbBDHuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 02:50:51 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so32916001igb.2
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 23:50:51 -0800 (PST)
In-Reply-To: <20150204062137.GD30631@kumar-pc.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 12:21 +0600, Kumar Sanghvi wrote:
> On Tuesday, February 02/03/15, 2015 at 21:58:29 -0800, Eric Dumazet wrote:
> > On Tue, 2015-02-03 at 10:50 +0530, Hariprasad Shenai wrote:
> > 
> > > @@ -1978,9 +2016,13 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
> > >  {
> > >  	unsigned int params;
> > >  	struct sge_rspq *q = container_of(napi, struct sge_rspq, napi);
> > > -	int work_done = process_responses(q, budget);
> > > +	int work_done = 0;
> > >  	u32 val;
> > >  
> > > +	if (!cxgb_poll_lock_napi(q))
> > > +		return work_done;
> > > +
> > 
> > 
> > This is very suspicious. Please take a look at commits
> > 
> > 24e579c8898aa641 ("bnx2x: fix napi poll return value for repoll") 
> > f104fedc0da126ab ("enic: fix rx napi poll return value")
> > 
> > for context.
> 
> Thanks Eric for pointing on this.
> So, this probably needs change after commit d75b1ade567ffab ("net: less interrupt masking in NAPI"), or
> is there something else that is missed ?

Right, you probably need to return budget here, not 0 (work_done == 0 at
this stage)
