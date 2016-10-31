From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] genetlink: fix error return code in
 genl_register_family()
Date: Mon, 31 Oct 2016 16:29:31 -0400 (EDT)
Message-ID: <20161031.162931.1238380166136072182.davem@davemloft.net>
References: <1477925583-7956-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, matti.vaittinen@nokia.com,
        tom@herbertland.com, johannes.berg@intel.com, pshelar@ovn.org,
        tycho.andersen@canonical.com, fw@strlen.de, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57550 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946401AbcJaU3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:29:33 -0400
In-Reply-To: <1477925583-7956-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 31 Oct 2016 14:53:03 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return error code -ENOMEM from the idr_alloc() error handling
> case instead of 0, as done elsewhere in this function.
> 
> Fixes: 2ae0f17df1cd ("genetlink: use idr to track families")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
 ...
> @@ -362,8 +362,10 @@ int genl_register_family(struct genl_family *family)
>  
>  	family->id = idr_alloc(&genl_fam_idr, family,
>  			       start, end + 1, GFP_KERNEL);
> -	if (!family->id)
> +	if (!family->id) {
> +		err = -ENOMEM;
>  		goto errout_locked;
> +	}
>  
>  	err = genl_validate_assign_mc_groups(family);
>  	if (err)

idr_alloc() returns negative error codes, not zero, on failure.

So we should return whatever idr_alloc() returns because it has
at least two error return cases (ENOSPC and ENOMEM).
