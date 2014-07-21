From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH -next] tipc: fix sparse non static symbol warnings
Date: Mon, 21 Jul 2014 10:36:40 +0800
Message-ID: <53CC7CB8.9090205@windriver.com>
References: <1405833268-6630-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <weiyj_lk@163.com>, Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63300 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbaGUChP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 22:37:15 -0400
In-Reply-To: <1405833268-6630-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2014 01:14 PM, weiyj_lk@163.com wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fixes the following sparse warnings:
> 
> net/tipc/socket.c:545:5: warning:
>  symbol 'tipc_sk_proto_rcv' was not declared. Should it be static?
> net/tipc/socket.c:2015:5: warning:
>  symbol 'tipc_ioctl' was not declared. Should it be static?
> 

Acked-by: Ying Xue <ying.xue@windriver.com>

> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  net/tipc/socket.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index de01622..42c3599 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -542,7 +542,8 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
>   * Returns 0 (TIPC_OK) if message was consumed, 1 (TIPC_FWD_MSG) if
>   * (CONN_PROBE_REPLY) message should be forwarded.
>   */
> -int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode, struct sk_buff *buf)
> +static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
> +			     struct sk_buff *buf)
>  {
>  	struct tipc_msg *msg = buf_msg(buf);
>  	struct tipc_port *port = &tsk->port;
> @@ -2012,7 +2013,7 @@ static int tipc_getsockopt(struct socket *sock, int lvl, int opt,
>  	return put_user(sizeof(value), ol);
>  }
>  
> -int tipc_ioctl(struct socket *sk, unsigned int cmd, unsigned long arg)
> +static int tipc_ioctl(struct socket *sk, unsigned int cmd, unsigned long arg)
>  {
>  	struct tipc_sioc_ln_req lnr;
>  	void __user *argp = (void __user *)arg;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
