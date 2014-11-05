From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 1/3] can: add can_is_canfd_skb() API
Date: Wed, 05 Nov 2014 08:22:13 -0800
Message-ID: <1415204533.13896.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, mkl@pengutronix.de, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415193393-30023-1-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-11-05 at 21:16 +0800, Dong Aisheng wrote:
> The CAN device drivers can use it to check if the frame to send is on
> CAN FD mode or normal CAN mode.
> 
> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
> Signed-off-by: Dong Aisheng <b29396@freescale.com>
> ---
> ChangesLog:
>  * v1->v2: change to skb->len == CANFD_MTU;
> ---
>  include/linux/can/dev.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
> index 6992afc..4c3919c 100644
> --- a/include/linux/can/dev.h
> +++ b/include/linux/can/dev.h
> @@ -99,6 +99,11 @@ inval_skb:
>  	return 1;
>  }
>  

This looks a bit strange to assume that skb->len == magical_value is CAN
FD. A comment would be nice.

> +static inline int can_is_canfd_skb(struct sk_buff *skb)

static inline bool can_is_canfd_skb(const struct sk_buff *skb)

> +{
> +	return skb->len == CANFD_MTU;
> +}
> +
>  /* get data length from can_dlc with sanitized can_dlc */
>  u8 can_dlc2len(u8 can_dlc);
>  


