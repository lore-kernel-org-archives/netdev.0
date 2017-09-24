From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: use idr to allocate bpf filter
 handles
Date: Sat, 23 Sep 2017 17:15:34 -0700 (PDT)
Message-ID: <20170923.171534.1037317649165173409.davem@davemloft.net>
References: <20170921234302.26558-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, chrism@mellanox.com,
        jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbdIXAPf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 20:15:35 -0400
In-Reply-To: <20170921234302.26558-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 21 Sep 2017 16:43:00 -0700

> @@ -421,27 +427,6 @@ static int cls_bpf_set_parms(struct net *net, struct tcf_proto *tp,
>  	return 0;
>  }
>  
> -static u32 cls_bpf_grab_new_handle(struct tcf_proto *tp,
> -				   struct cls_bpf_head *head)
> -{
> -	unsigned int i = 0x80000000;
> -	u32 handle;
> -
> -	do {
> -		if (++head->hgen == 0x7FFFFFFF)
> -			head->hgen = 1;
> -	} while (--i > 0 && cls_bpf_get(tp, head->hgen));
> -
> -	if (unlikely(i == 0)) {
> -		pr_err("Insufficient number of handles\n");
> -		handle = 0;
> -	} else {
> -		handle = head->hgen;
> -	}
> -
> -	return handle;
> -}
> -

If I read the code properly, the existing code allows IDs from '1' to
and including '0x7ffffffe', whereas the new code allows up to and
including '0x7ffffffff'.

Whether intentional or not this is a change in behavior.  If it's OK,
it should be at least documented either in a comment or in the
commit log itself.

Similarly for your other scheduler IDR changes.

Thanks.
