From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next] net_sched: move tp->root allocation into route4_init()
Date: Thu, 05 Mar 2015 17:26:13 +0300
Message-ID: <54F86785.70906@cogentembedded.com>
References: <1425528704-21646-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33448 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbbCEO0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 09:26:17 -0500
Received: by lbdu14 with SMTP id u14so30480041lbd.0
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 06:26:16 -0800 (PST)
In-Reply-To: <1425528704-21646-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/5/2015 7:11 AM, Cong Wang wrote:

> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   net/sched/cls_route.c | 14 +++++++-------
>   1 file changed, 7 insertions(+), 7 deletions(-)

> diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
> index 2ecd246..bb8a602 100644
> --- a/net/sched/cls_route.c
> +++ b/net/sched/cls_route.c
> @@ -258,6 +258,13 @@ static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
>
>   static int route4_init(struct tcf_proto *tp)
>   {
> +	struct route4_head *head;
> +
> +	head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);

    Hm, checkpatch.pl should have suggested using sizeof(*head) instead...

> +	if (head == NULL)

    And using !head instead.

> +		return -ENOBUFS;
> +
> +	rcu_assign_pointer(tp->root, head);
>   	return 0;
>   }

WBR, Sergei
