From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: ipv4: refine the logic for determining daddr
 in ip_queue_xmit.
Date: Mon, 14 Jan 2013 20:57:09 -0800
Message-ID: <1358225829.8744.4508.camel@edumazet-glaptop>
References: <1358225255-30973-1-git-send-email-harvey.huawei.yang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Harvey Yang <harvey.huawei.yang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358225255-30973-1-git-send-email-harvey.huawei.yang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-01-15 at 12:47 +0800, Harvey Yang wrote:
> The destination address daddr is faddr if source route option is set, otherwise it is inet_daddr. So use if-else to assign the value.
> 
> Signed-off-by: Harvey Yang <harvey.huawei.yang@gmail.com>
> ---
>  net/ipv4/ip_output.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 3e98ed2..22b738c 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -349,10 +349,10 @@ int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
>  		__be32 daddr;
>  
>  		/* Use correct destination address if we have options. */
> -		daddr = inet->inet_daddr;
>  		if (inet_opt && inet_opt->opt.srr)
>  			daddr = inet_opt->opt.faddr;
> -
> +		else
> +			daddr = inet->inet_daddr;
>  		/* If this fails, retransmit mechanism of transport layer will
>  		 * keep trying until route appears or the connection times
>  		 * itself out.

Current code is faster, srr is not often used.
