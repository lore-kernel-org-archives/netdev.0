From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: check for null sk before deferencing it via the call
 to sock_net
Date: Fri, 8 Sep 2017 19:46:13 +0200
Message-ID: <f5ce1047-eb37-151a-c7b7-9b47b70789f7@hartkopp.net>
References: <20170908150235.2931-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S . Miller" <davem@davemloft.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908150235.2931-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09/08/2017 05:02 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The assignment of net via call sock_net will dereference sk. This
> is performed before a sanity null check on sk, so there could be
> a potential null dereference on the sock_net call if sk is null.
> Fix this by assigning net after the sk null check. Also replace
> the sk == NULL with the more usual !sk idiom.
> 
> Detected by CoverityScan CID#1431862 ("Dereference before null check")
> 
> Fixes: 384317ef4187 ("can: network namespace support for CAN_BCM protocol")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>


Thanks Collin!

> ---
>   net/can/bcm.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 47a8748d953a..a3791674b8ce 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -1493,13 +1493,14 @@ static int bcm_init(struct sock *sk)
>   static int bcm_release(struct socket *sock)
>   {
>   	struct sock *sk = sock->sk;
> -	struct net *net = sock_net(sk);
> +	struct net *net;
>   	struct bcm_sock *bo;
>   	struct bcm_op *op, *next;
>   
> -	if (sk == NULL)
> +	if (!sk)
>   		return 0;
>   
> +	net = sock_net(sk);
>   	bo = bcm_sk(sk);
>   
>   	/* remove bcm_ops, timer, rx_unregister(), etc. */
> 
