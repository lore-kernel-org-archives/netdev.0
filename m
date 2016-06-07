From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 1/2] net: cls_u32: fix error code for invalid flags
Date: Tue, 7 Jun 2016 08:46:17 -0700
Message-ID: <5756EC49.10000@gmail.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
 <1465226208-32097-2-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33483 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbcFGPq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 11:46:29 -0400
Received: by mail-pa0-f68.google.com with SMTP id di3so14473875pab.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 08:46:29 -0700 (PDT)
In-Reply-To: <1465226208-32097-2-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-06 08:16 AM, Jakub Kicinski wrote:
> 'err' variable is not set in this test, we would return whatever
> previous test set 'err' to.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  net/sched/cls_u32.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 079b43b3c5d2..b17e090f2fe1 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -863,7 +863,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>  	if (tb[TCA_U32_FLAGS]) {
>  		flags = nla_get_u32(tb[TCA_U32_FLAGS]);
>  		if (!tc_flags_valid(flags))
> -			return err;
> +			return -EINVAL;
>  	}
>  
>  	n = (struct tc_u_knode *)*arg;
> 

Yep, I agree it is nice to get an error on this case.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
