From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net/sched: remove redundant null check on head
Date: Wed, 3 May 2017 17:12:12 +0200
Message-ID: <20170503151212.GD2077@nanopsycho.orion>
References: <20170503135040.32023-1-colin.king@canonical.com>
 <5909E75B.30305@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin King <colin.king@canonical.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5909E75B.30305@bfs.de>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, May 03, 2017 at 04:21:15PM CEST, wharms@bfs.de wrote:
>
>
>Am 03.05.2017 15:50, schrieb Colin King:
>> From: Colin Ian King <colin.king@canonical.com>
>> 
>> head is previously null checked and so the 2nd null check on head
>> is redundant and therefore can be removed.
>> 
>> Detected by CoverityScan, CID#1399505 ("Logically dead code")
>> 
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> ---
>>  net/sched/cls_matchall.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>> 
>> diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
>> index 2efb36c08f2a..dee469fed967 100644
>> --- a/net/sched/cls_matchall.c
>> +++ b/net/sched/cls_matchall.c
>> @@ -203,8 +203,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
>>  
>>  	*arg = (unsigned long) head;
>>  	rcu_assign_pointer(tp->root, new);
>> -	if (head)
>> -		call_rcu(&head->rcu, mall_destroy_rcu);
>> +	call_rcu(&head->rcu, mall_destroy_rcu);
>>  	return 0;
>>  
>>  err_replace_hw_filter:
>
>
>if someone cares .. the err=0 in the the line above the patch is also useless
>because err is never used again. Merging both if will save 1 indent level.
>
> err = mall_replace_hw_filter(tp, new, (unsigned long) new);
> if (err && tc_skip_sw(flags) )
>	goto errout;


true, however unrelated to this patch :)

Please submit as a separate patch.

Thanks.
