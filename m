From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH]: suspicious unlikely usage in tcp_transmit_skb()
Date: Tue, 25 Apr 2006 10:01:49 -0700
Message-ID: <20060425100149.636d6a1d@localhost.localdomain>
References: <444D5E73.7020803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:157 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932226AbWDYRCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 13:02:10 -0400
To: Hua Zhong <hzhong@gmail.com>
In-Reply-To: <444D5E73.7020803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Apr 2006 16:25:39 -0700
Hua Zhong <hzhong@gmail.com> wrote:

> Hi,
> 
> I am developing a profiling tool to check if likely/unlikely usages are wise. I find that the following one is always a miss:
> 
>       # Hit    # miss Function:Filename@Line
> !         0     50505 tcp_transmit_skb():net/ipv4/tcp_output.c@468
> 
> There is a chance that my tool is buggy, but I just want to confirm with you whether this does look suspicious and what your opinion is.
> 
> Signed-off-by: Hua Zhong <hzhong@gmail.com>
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index a28ae59..743016b 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -465,7 +465,7 @@ #define SYSCTL_FLAG_SACK    0x4
>         TCP_INC_STATS(TCP_MIB_OUTSEGS);
>  
>         err = icsk->icsk_af_ops->queue_xmit(skb, 0);
> -       if (unlikely(err <= 0))
> +       if (likely(err <= 0))
>                 return err;
>  
>         tcp_enter_cwr(sk);

How about just taking off the likely/unlikely in this case.
