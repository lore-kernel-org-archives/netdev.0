From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: catch signed nla_len() retval in tcf_simp_init()
Date: Wed, 16 Apr 2008 21:37:12 -0700 (PDT)
Message-ID: <20080416.213712.78410382.davem@davemloft.net>
References: <4806C501.20300@tiscali.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: 12o3l@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38230
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbYDQEhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 00:37:11 -0400
In-Reply-To: <4806C501.20300@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <12o3l@tiscali.nl>
Date: Thu, 17 Apr 2008 05:33:21 +0200

> 'datalen' is unsigned, use 'ret' instead to catch a negative return value.
> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
> index fbde461..b78d015 100644
> --- a/net/sched/act_simple.c
> +++ b/net/sched/act_simple.c
> @@ -114,9 +114,10 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
>  	if (defdata == NULL)
>  		return -EINVAL;
>  
> -	datalen = nla_len(tb[TCA_DEF_DATA]);
> -	if (datalen <= 0)
> +	ret = nla_len(tb[TCA_DEF_DATA]);
> +	if (ret <= 0)
>  		return -EINVAL;
> +	datalen = ret;
>  
>  	pc = tcf_hash_check(parm->index, a, bind, &simp_hash_info);
>  	if (!pc) {

This clobbers 'ret' which is compared to ACT_P_CREATED
later in the function.  If the !pc branch below this code
is not taken, ret must be left at it's initial value of
zero.  Now, it will take on some non-zero positive value
which is not correct.

