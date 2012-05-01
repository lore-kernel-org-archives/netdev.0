From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] Sometimes the ISDN chip only controls the D-channel
Date: Tue, 01 May 2012 13:30:07 -0400 (EDT)
Message-ID: <20120501.133007.569588994121475807.davem@davemloft.net>
References: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
	<1335613404-10187-4-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700Ab2EARaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 13:30:12 -0400
In-Reply-To: <1335613404-10187-4-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Sat, 28 Apr 2012 13:43:19 +0200

> The B-channels are only accessed via the PCM backplane.
> Add infrastruckture for this special mode.
> 
> Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>

I dread reviewing these ISDN patch sets because they are so
full of problems, and it's so damn obvious how little care is
put into preparing them.

What I see is that you put the minimum amount of work necessary
into splitting up your huge ISDN patch set submission into more
managable pieces, and as a result you are introducing problems.

> diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
> index abe2d69..502bcf1 100644
> --- a/drivers/isdn/mISDN/socket.c
> +++ b/drivers/isdn/mISDN/socket.c
> @@ -270,6 +270,7 @@ data_sock_release(struct socket *sock)
>  		break;
>  	case ISDN_P_LAPD_TE:
>  	case ISDN_P_LAPD_NT:
> +	case ISDN_P_B_PCM:
>  	case ISDN_P_B_RAW:
>  	case ISDN_P_B_HDLC:
>  	case ISDN_P_B_X75SLP:

Ok, that's fine.

> @@ -148,6 +149,8 @@ struct bchannel {
>  	u_int			state;
>  	void			*hw;
>  	int			slot;	/* multiport card channel slot */
> +	int			pcm_tx;	/* PCM tx slot nr */
> +	int			pcm_rx;	/* PCM rx slot nr */
>  	struct timer_list	timer;
>  	/* receive data */
>  	struct sk_buff		*rx_skb;

But what the hell is this?  These structure members are unused by
this patch, and in fact no patch in your entire series uses them.

> @@ -360,8 +360,8 @@ clear_channelmap(u_int nr, u_char *map)
>  #define MISDN_CTRL_LOOP			0x0001
>  #define MISDN_CTRL_CONNECT		0x0002
>  #define MISDN_CTRL_DISCONNECT		0x0004
> -#define MISDN_CTRL_PCMCONNECT		0x0010
> -#define MISDN_CTRL_PCMDISCONNECT	0x0020
> +#define MISDN_CTRL_GET_PCM_SLOTS	0x0010
> +#define MISDN_CTRL_SET_PCM_SLOTS	0x0020
>  #define MISDN_CTRL_SETPEER		0x0040
>  #define MISDN_CTRL_UNSETPEER		0x0080
>  #define MISDN_CTRL_RX_OFF		0x0100

Another completely unrelated change, nothing in this patch uses
these new defines.

> @@ -381,6 +381,10 @@ clear_channelmap(u_int nr, u_char *map)
>  #define MISDN_CTRL_HFC_WD_INIT		0x4009
>  #define MISDN_CTRL_HFC_WD_RESET		0x400A
>  
> +/* special PCM slot numbers */
> +#define MISDN_PCM_SLOT_DISABLE	-1	/* PCM disabled */
> +#define MISDN_PCM_SLOT_IGNORE	-2	/* PCM setting will be not changed */
> +
>  /* socket options */
>  #define MISDN_TIME_STAMP		0x0001
>  

Same thing.

> @@ -389,6 +393,7 @@ struct mISDN_ctrl_req {
>  	int		channel;
>  	int		p1;
>  	int		p2;
> +	int		p3;
>  };
>  
>  /* muxer options */

And again, same problem.

You really need to get your act in gear and prepare your patches
properly, so that they don't have unrelated changes in them.

This is not amateur hour.
