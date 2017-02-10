From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove member 'max' of struct scm_fp_list
Date: Fri, 10 Feb 2017 10:25:43 -0500 (EST)
Message-ID: <20170210.102543.2139355880844380775.davem@davemloft.net>
References: <1486728673-19466-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41446 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751767AbdBJQVG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 11:21:06 -0500
In-Reply-To: <1486728673-19466-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Fri, 10 Feb 2017 20:11:13 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> SCM_MAX_FD can fully replace it.
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

I don't think so:

> @@ -341,7 +332,6 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
>  	if (new_fpl) {
>  		for (i = 0; i < fpl->count; i++)
>  			get_file(fpl->fp[i]);
> -		new_fpl->max = new_fpl->count;
>  		new_fpl->user = get_uid(fpl->user);

It's not set the SCM_MAX_FD here, it's set to whatever fpl->count is.

In other words, your patch breaks things.
