From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [patch] net/sched: remove unneeded NULL check
Date: Mon, 16 Aug 2010 10:14:32 +0000
Message-ID: <20100816101432.GB8547@ff.dom.local>
References: <20100814210949.GB645@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55588 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab0HPKOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 06:14:36 -0400
Content-Disposition: inline
In-Reply-To: <20100814210949.GB645@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote:
> There is no need to check "s".  nla_data() doesn't return NULL.  Also we
> already dereferenced "s" at this point so it would have oopsed ealier if
> it were NULL.

Looks OK to me.

Jarek P.

> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 408eea7..6fb3d41 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -360,7 +360,7 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
>  		tsize = nla_len(tb[TCA_STAB_DATA]) / sizeof(u16);
>  	}
>  
> -	if (!s || tsize != s->tsize || (!tab && tsize > 0))
> +	if (tsize != s->tsize || (!tab && tsize > 0))
>  		return ERR_PTR(-EINVAL);
>  
>  	spin_lock(&qdisc_stab_lock);
> --
