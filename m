From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] can: test size of struct sockaddr
Date: Sat, 15 Jan 2011 18:08:54 +0100
Message-ID: <4D31D4A6.4040701@hartkopp.net>
References: <20110114172321.GB331@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110114172321.GB331-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
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

On 14.01.2011 18:23, Kurt Van Dijck wrote:
> I think this patch makes the CAN socket code comform to the
> manpages of sendmsg & recvmsg.

Hello Kurt,

if you check similar code sniplets in the kernel you would see, that in
recvmsg()-cases the given namelen is not used from userspace.

If msg->msg_name is not NULL the msg_namelen is just set by the kernel. E.g.
see af_packet.c, af_econet.c, etc.

So the code in candump.c setting the msg_namelen before recvmsg() is obviously
obsolete ...

Btw. your two patches below for bcm_sendmsg() and raw_sendmesg() look good.

If you would like to resubmit these two patches, you may add my Acked-by

Thanks,
Oliver



> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 6faa825..dc0d5d6 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -1256,6 +1256,9 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
>  		struct sockaddr_can *addr =
>  			(struct sockaddr_can *)msg->msg_name;
>  
> +		if (msg->msg_namelen < sizeof(*addr))
> +			return -EINVAL;
> +
>  		if (addr->can_family != AF_CAN)
>  			return -EINVAL;
>  


> diff --git a/net/can/raw.c b/net/can/raw.c
> index e88f610..e68a6d3 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -649,6 +649,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
>  		struct sockaddr_can *addr =
>  			(struct sockaddr_can *)msg->msg_name;
>  
> +		if (msg->msg_namelen < sizeof(*addr))
> +			return -EINVAL;
> +
>  		if (addr->can_family != AF_CAN)
>  			return -EINVAL;
>  
