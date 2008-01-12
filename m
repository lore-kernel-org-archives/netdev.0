From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 001/001] ipv4: enable use of 240/4 address space
Date: Sat, 12 Jan 2008 14:47:29 +0900 (JST)
Message-ID: <20080112.144729.67503025.yoshfuji@linux-ipv6.org>
References: <20080108011057.GA21168@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: vaf@cisco.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761821AbYALFrf@vger.kernel.org>
In-Reply-To: <20080108011057.GA21168@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20080108011057.GA21168@cisco.com> (at Mon, 7 Jan 2008 17:10:57 -0800), Vince Fuller <vaf@cisco.com> says:

>  #define IN_MULTICAST_NET	0xF0000000
>  
> +#define IN_CLASSE(a)		((((long int) (a)) & 0xf0000000) == 0xf0000000)
> +#define	IN_CLASSE_NET		0xffffff00
> +#define	IN_CLASSE_NSHIFT	8
> +#define	IN_CLASSE_HOST		(0xffffffff & ~IN_CLASSE_NET)
> +
> +/* 
> + * these are no longer used
>  #define	IN_EXPERIMENTAL(a)	((((long int) (a)) & 0xf0000000) == 0xf0000000)
>  #define	IN_BADCLASS(a)		IN_EXPERIMENTAL((a))
> +*/

Please do not remove this, but have these instead:

#define IN_EXPERIMENTAL(a)	IN_CLASSE((a))
#define IN_BADCASS(a)		IN_CLASSE((a))

And, I think it is good to remove BADCLASS() (inside
#ifdef __KERNEL__ .. #endif) because we do not have its users
any longer, right?

Regards,

--yoshfuji
