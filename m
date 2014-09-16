From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Patch net-next v2] net_sched: fix memory leak in cls_tcindex
Date: Mon, 15 Sep 2014 17:11:48 -0700
Message-ID: <54178044.1010407@gmail.com>
References: <1410824623-27516-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:35027 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267AbaIPAMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 20:12:09 -0400
Received: by mail-ob0-f173.google.com with SMTP id m8so3098981obr.18
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 17:12:08 -0700 (PDT)
In-Reply-To: <1410824623-27516-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2014 04:43 PM, Cong Wang wrote:
> Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>
> v2: fix err = -ENOMEM
>
>   net/sched/cls_tcindex.c | 17 ++++++++++-------
>   1 file changed, 10 insertions(+), 7 deletions(-)
>
> diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
> index dd2d691..ee52542 100644
> --- a/net/sched/cls_tcindex.c
> +++ b/net/sched/cls_tcindex.c
> @@ -242,8 +242,10 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
>   	 * perfect hash and hash pointers from old data.
>   	 */
>   	cp = kzalloc(sizeof(*cp), GFP_KERNEL);
> -	if (!cp)
> -		return -ENOMEM;
> +	if (!cp) {
> +		err = -ENOMEM;
> +		goto errout;
> +	}

Thanks for fixing up tcindex for me I see now it was missing
from my test scripts. Along with cls_bpf so I'll need to go
back and test that as well.

Acked-By: John Fastabend <john.r.fastabend@gmail.com>


-- 
John Fastabend         Intel Corporation
