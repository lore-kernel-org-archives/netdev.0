From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [Patch net-next] net_sched: fix suspicious RCU usage in cls_bpf_classify()
Date: Mon, 15 Sep 2014 14:30:19 -0700
Message-ID: <54175A6B.90602@intel.com>
References: <1410816110-10354-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21175 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755418AbaIOVaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 17:30:39 -0400
In-Reply-To: <1410816110-10354-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2014 02:21 PM, Cong Wang wrote:
> Fixes: commit 1f947bf151e90ec0baad2948 ("net: sched: rcu'ify cls_bpf")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/cls_bpf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
> index 6a7386e..4e3f5bf 100644
> --- a/net/sched/cls_bpf.c
> +++ b/net/sched/cls_bpf.c
> @@ -52,7 +52,7 @@ static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
>  static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  			    struct tcf_result *res)
>  {
> -	struct cls_bpf_head *head = rcu_dereference(tp->root);
> +	struct cls_bpf_head *head = rcu_dereference_bh(tp->root);
>  	struct cls_bpf_prog *prog;
>  	int ret;
>  
> 

you beat me to it.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
