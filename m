From: Oliver Hartkopp <oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
Subject: Re: [PATCH 1/2] can: bfin_can: simplify xmit
	id1 setup
Date: Fri, 24 Jun 2011 12:46:22 +0200
Message-ID: <4E046AFE.5000109@volkswagen.de>
References: <1308861380-27485-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Urs Thuermann <urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
To: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <1308861380-27485-1-git-send-email-vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

Am 23.06.2011 22:36, schrieb Mike Frysinger:
> If we look closely, the 4 writes to TRANSMIT_CHL.id1 can be collapsed
> down into much simpler code.  So do just that.

Hello Mike,

unfortunately you addressed the wrong people to ack your patch.

In MAINTAINERS there are entries for the CAN NETWORK LAYER and for CAN 
NETWORK DRIVERS which addresses the code in drivers/net/can/...

Additionally you should address your patch to the author of the driver 
(Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>).

Tnx & best regards,
Oliver



>
> This also fixes a build failure due to the I/O macros no longer
> getting pulled in.  Their minor (and accidental) usage here gets
> dropped as part of the unification.
>
> Signed-off-by: Mike Frysinger<vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> ---
>   drivers/net/can/bfin_can.c |   21 ++++++---------------
>   1 files changed, 6 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
> index b6e890d..dc6ef4a 100644
> --- a/drivers/net/can/bfin_can.c
> +++ b/drivers/net/can/bfin_can.c
> @@ -243,21 +243,12 @@ static int bfin_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	/* fill id */
>   	if (id&  CAN_EFF_FLAG) {
>   		bfin_write16(&reg->chl[TRANSMIT_CHL].id0, id);
> -		if (id&  CAN_RTR_FLAG)
> -			writew(((id&  0x1FFF0000)>>  16) | IDE | AME | RTR,
> -					&reg->chl[TRANSMIT_CHL].id1);
> -		else
> -			writew(((id&  0x1FFF0000)>>  16) | IDE | AME,
> -					&reg->chl[TRANSMIT_CHL].id1);
> -
> -	} else {
> -		if (id&  CAN_RTR_FLAG)
> -			writew((id<<  2) | AME | RTR,
> -				&reg->chl[TRANSMIT_CHL].id1);
> -		else
> -			bfin_write16(&reg->chl[TRANSMIT_CHL].id1,
> -					(id<<  2) | AME);
> -	}
> +		val = ((id&  0x1FFF0000)>>  16) | IDE;
> +	} else
> +		val = (id<<  2);
> +	if (id&  CAN_RTR_FLAG)
> +		val |= RTR;
> +	bfin_write16(&reg->chl[TRANSMIT_CHL].id1, val | AME);
>
>   	/* fill payload */
>   	for (i = 0; i<  8; i += 2) {
