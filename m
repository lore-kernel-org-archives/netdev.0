From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: sched: don't use GFP_KERNEL under spin lock
Date: Tue, 05 Sep 2017 07:10:21 -0700
Message-ID: <1504620621.15310.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170905105442.30972-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
        Chris Mi <chrism@mellanox.com>, xiyou.wangcong@gmail.com,
        jhs@mojatatu.com, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34014 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbdIEOKX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 10:10:23 -0400
Received: by mail-pg0-f65.google.com with SMTP id v82so1412576pgb.1
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 07:10:23 -0700 (PDT)
In-Reply-To: <20170905105442.30972-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-05 at 03:54 -0700, Jakub Kicinski wrote:
> The new TC IDR code uses GFP_KERNEL under spinlocks.  Which leads
> to:

> ...
> 
> Fixes: 65a206c01e8e ("net/sched: Change act_api and act_xxx modules to use IDR")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---
>  net/sched/act_api.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 0eb545bcb247..a48e4b45722d 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -298,7 +298,7 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
>  	if (!index) {


		idr_preload(GFP_KERNEL);

>  		spin_lock_bh(&idrinfo->lock);
>  		err = idr_alloc_ext(idr, NULL, &idr_index, 1, 0,
> -				    GFP_KERNEL);
> +				    GFP_ATOMIC);
>  		spin_unlock_bh(&idrinfo->lock);
>  		if (err) {
>  err3:
> @@ -309,7 +309,7 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
>  	} else {

		idr_preload(GFP_KERNEL);

>  		spin_lock_bh(&idrinfo->lock);
>  		err = idr_alloc_ext(idr, NULL, NULL, index, index + 1,
> -				    GFP_KERNEL);
> +				    GFP_ATOMIC);
>  		spin_unlock_bh(&idrinfo->lock);
>  		if (err)
>  			goto err3;
