From: Ying Xue <ying.xue0@gmail.com>
Subject: Re: [PATCH -next] tipc: fix imbalance read_unlock_bh in
 __tipc_nl_add_monitor()
Date: Thu, 28 Jul 2016 17:50:13 +0800
Message-ID: <5799D555.3010905@gmail.com>
References: <1469671669-12829-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Wei Yongjun <weiyj.lk@gmail.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34342 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755337AbcG1JvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 05:51:01 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so3444342pfb.1
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2016 02:51:00 -0700 (PDT)
In-Reply-To: <1469671669-12829-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2016 10:07 AM, Wei Yongjun wrote:
> In the error handling case of nla_nest_start() failed read_unlock_bh()
> is called  to unlock a lock that had not been taken yet. sparse warns
> about the context imbalance as the following:
> 
> net/tipc/monitor.c:799:23: warning:
>  context imbalance in '__tipc_nl_add_monitor' - different lock contexts for basic block
> 
> Fixes: cf6f7e1d5109 ('tipc: dump monitor attributes')
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/monitor.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/tipc/monitor.c b/net/tipc/monitor.c
> index be70a57..b62caa1 100644
> --- a/net/tipc/monitor.c
> +++ b/net/tipc/monitor.c
> @@ -794,10 +794,10 @@ int __tipc_nl_add_monitor(struct net *net, struct tipc_nl_msg *msg,
>  	return 0;
>  
>  attr_msg_full:
> +	read_unlock_bh(&mon->lock);
>  	nla_nest_cancel(msg->skb, attrs);
>  msg_full:
>  	genlmsg_cancel(msg->skb, hdr);
> -	read_unlock_bh(&mon->lock);
>  
>  	return -EMSGSIZE;
>  }
> 
> 
