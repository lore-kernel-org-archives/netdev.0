From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATH v2 net-next] net: remove member 'max' of struct scm_fp_list
Date: Sun, 12 Feb 2017 13:54:28 +0300
Message-ID: <181c529e-fc20-4b21-1e94-b069554769ca@cogentembedded.com>
References: <1486780603-2888-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:35599 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdBLKy3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 05:54:29 -0500
Received: by mail-lf0-f46.google.com with SMTP id n124so39935779lfd.2
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 02:54:29 -0800 (PST)
In-Reply-To: <1486780603-2888-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/11/2017 5:36 AM, yuan linyu wrote:

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
>
> 'max' only used at three places in scm.c,
> 1. in scm_fp_copy(), fpl->max = SCM_MAX_FD;
> 2. in scm_fp_copy(), if (fpl->count + num > fpl->max)
> 3. in scm_fp_dup(), new_fpl->max = new_fpl->count;
> at place 2, fpl->max can be replaced with SCM_MAX_FD.
> no other place read this 'max' again, so it can be removed.
>
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> ---
> v1->v2:
>     update commit log to describe correct reason to remove 'max'
>
>  include/net/scm.h |  3 +--
>  net/core/scm.c    | 20 +++++---------------
>  2 files changed, 6 insertions(+), 17 deletions(-)
>
> diff --git a/include/net/scm.h b/include/net/scm.h
> index 59fa93c..1301227 100644
> --- a/include/net/scm.h
> +++ b/include/net/scm.h
> @@ -19,8 +19,7 @@ struct scm_creds {
>  };
>
>  struct scm_fp_list {
> -	short			count;
> -	short			max;
> +	unsigned int	count;

    Why break the alignment in the 2nd column?

>  	struct user_struct	*user;
>  	struct file		*fp[SCM_MAX_FD];
>  };
[...]

MBR, Sergei
