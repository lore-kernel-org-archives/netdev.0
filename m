From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] can: make struct can_proto const
Date: Wed, 04 May 2011 22:34:50 +0200
Message-ID: <4DC1B86A.40308@hartkopp.net>
References: <20110504044057.GC278@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110504044057.GC278-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04.05.2011 06:40, Kurt Van Dijck wrote:
> commit 53914b67993c724cec585863755c9ebc8446e83b had the
> same message. That commit did put everything in place but
> did not make can_proto const itself.
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
> 

Acked-by: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>

Thanks Kurt!

> diff --git a/include/linux/can/core.h b/include/linux/can/core.h
> index 6f70a6d..5ce6b5d 100644
> --- a/include/linux/can/core.h
> +++ b/include/linux/can/core.h
> @@ -44,8 +44,8 @@ struct can_proto {
>  
>  /* function prototypes for the CAN networklayer core (af_can.c) */
>  
> -extern int  can_proto_register(struct can_proto *cp);
> -extern void can_proto_unregister(struct can_proto *cp);
> +extern int  can_proto_register(const struct can_proto *cp);
> +extern void can_proto_unregister(const struct can_proto *cp);
>  
>  extern int  can_rx_register(struct net_device *dev, canid_t can_id,
>  			    canid_t mask,
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index a8dcaa4..5b52762 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -84,7 +84,7 @@ static DEFINE_SPINLOCK(can_rcvlists_lock);
>  static struct kmem_cache *rcv_cache __read_mostly;
>  
>  /* table of registered CAN protocols */
> -static struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
> +static const struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
>  static DEFINE_MUTEX(proto_tab_lock);
>  
>  struct timer_list can_stattimer;   /* timer for statistics update */
> @@ -115,9 +115,9 @@ static void can_sock_destruct(struct sock *sk)
>  	skb_queue_purge(&sk->sk_receive_queue);
>  }
>  
> -static struct can_proto *can_try_module_get(int protocol)
> +static const struct can_proto *can_try_module_get(int protocol)
>  {
> -	struct can_proto *cp;
> +	const struct can_proto *cp;
>  
>  	rcu_read_lock();
>  	cp = rcu_dereference(proto_tab[protocol]);
> @@ -132,7 +132,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
>  		      int kern)
>  {
>  	struct sock *sk;
> -	struct can_proto *cp;
> +	const struct can_proto *cp;
>  	int err = 0;
>  
>  	sock->state = SS_UNCONNECTED;
> @@ -691,7 +691,7 @@ drop:
>   *  -EBUSY  protocol already in use
>   *  -ENOBUF if proto_register() fails
>   */
> -int can_proto_register(struct can_proto *cp)
> +int can_proto_register(const struct can_proto *cp)
>  {
>  	int proto = cp->protocol;
>  	int err = 0;
> @@ -728,7 +728,7 @@ EXPORT_SYMBOL(can_proto_register);
>   * can_proto_unregister - unregister CAN transport protocol
>   * @cp: pointer to CAN protocol structure
>   */
> -void can_proto_unregister(struct can_proto *cp)
> +void can_proto_unregister(const struct can_proto *cp)
>  {
>  	int proto = cp->protocol;
>  
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 8a6a05e..cced806 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -1601,7 +1601,7 @@ static struct proto bcm_proto __read_mostly = {
>  	.init       = bcm_init,
>  };
>  
> -static struct can_proto bcm_can_proto __read_mostly = {
> +static const struct can_proto bcm_can_proto = {
>  	.type       = SOCK_DGRAM,
>  	.protocol   = CAN_BCM,
>  	.ops        = &bcm_ops,
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 0eb39a7..dea99a6 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -774,7 +774,7 @@ static struct proto raw_proto __read_mostly = {
>  	.init       = raw_init,
>  };
>  
> -static struct can_proto raw_can_proto __read_mostly = {
> +static const struct can_proto raw_can_proto = {
>  	.type       = SOCK_RAW,
>  	.protocol   = CAN_RAW,
>  	.ops        = &raw_ops,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
