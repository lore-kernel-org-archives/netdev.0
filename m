From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] net: use __packed annotation (fwd)
Date: Wed, 02 Jun 2010 19:26:57 -0700
Message-ID: <1275532017.23599.127.camel@Joe-Laptop.home>
References: <20100603021542.585D42436B@mail.perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2637 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933577Ab0FCC06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 22:26:58 -0400
In-Reply-To: <20100603021542.585D42436B@mail.perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some comments:

[]

> diff --git a/include/linux/ncp_fs_sb.h b/include/linux/ncp_fs_sb.h
> index 5ec9ca6..8da05bc 100644
> --- a/include/linux/ncp_fs_sb.h
> +++ b/include/linux/ncp_fs_sb.h
> @@ -104,13 +104,13 @@ struct ncp_server {
>  
>  		unsigned int state;		/* STREAM only: receiver state */
>  		struct {
> -			__u32 magic __attribute__((packed));
> -			__u32 len __attribute__((packed));
> -			__u16 type __attribute__((packed));
> -			__u16 p1 __attribute__((packed));
> -			__u16 p2 __attribute__((packed));
> -			__u16 p3 __attribute__((packed));
> -			__u16 type2 __attribute__((packed));
> +			__u32 magic __packed;
> +			__u32 len __packed;
> +			__u16 type __packed;
> +			__u16 p1 __packed;
> +			__u16 p2 __packed;
> +			__u16 p3 __packed;
> +			__u16 type2 __packed;
>  		} buf;				/* STREAM only: temporary buffer */

This could probably just be
		struct {
			__u32 magic;
			__u32 len;
			__u16 type;
			__u16 p1;
			__u16 p2;
			__u16 p3;
			__u16 type2;
 		} __packed buf;				/* STREAM only: temporary buffer */
[]

> diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
> index f28ad2c..499c045 100644
> --- a/net/iucv/iucv.c
> +++ b/net/iucv/iucv.c
> @@ -1463,7 +1463,7 @@ struct iucv_path_pending {
>  	u32 res3;
>  	u8  ippollfg;
>  	u8  res4[3];
> -} __attribute__ ((packed));
> +} __packed;

iucv also has some structs that are __attribute__ ((packed,aligned(8)));

Perhaps those should become: __packed __aligned(8) instead of
leaving them as is.



