From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] work around 5701 misalignment
Date: Wed, 13 Oct 2004 16:57:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416D96B8.5090204@pobox.com>
References: <200410131554.19845.jbarnes@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesse Barnes <jbarnes@sgi.com>
In-Reply-To: <200410131554.19845.jbarnes@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jesse Barnes wrote:
> --- a/linux/drivers/net/tg3.c	2004-10-13 15:25:03.000000000 -0500
> +++ b/linux/drivers/net/tg3.c	2004-10-13 15:14:45.000000000 -0500
> @@ -2352,7 +2352,12 @@
>  
>  		len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) - 4; /* omit crc */
>  
> -		if (len > RX_COPY_THRESHOLD) {
> +		if (len > RX_COPY_THRESHOLD
> +#if defined(CONFIG_UNALIGNED_EXPENSIVE)
> +                                && tp->rx_offset == 2
> +#endif


hmmm, the normal solution is to give RX_COPY_THRESHOLD a per-arch value. 
  Grep for 'rx_copybreak' in bunches of net drivers.

DaveM might squirm a bit but IMHO RX_COPY_THRESHOLD really is 
platform-dependent.

	Jeff
