From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/6] bnx2: Fix excessive stack usage
Date: Mon, 23 May 2005 21:42:59 -0400
Message-ID: <429286A3.1060606@pobox.com>
References: <1116892439.4908.1.camel@rh4> <1116894307.4908.28.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1116894307.4908.28.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> diff -Nru 10/drivers/net/bnx2.c 11/drivers/net/bnx2.c
> --- 10/drivers/net/bnx2.c	2005-05-23 10:20:02.000000000 -0700
> +++ 11/drivers/net/bnx2.c	2005-05-23 10:20:20.000000000 -0700
> @@ -1138,13 +1138,20 @@
>  	}
>  }
>  
> -static void
> +static int
>  bnx2_alloc_bad_rbuf(struct bnx2 *bp)
>  {
> -	u16 good_mbuf[512];
> +	u16 *good_mbuf;
>  	u32 good_mbuf_cnt;
>  	u32 val;
>  
> +	good_mbuf = kmalloc(512 * sizeof(u16), GFP_KERNEL);
> +	if (good_mbuf == NULL) {
> +		printk(KERN_ERR PFX "Failed to allocate memory in "
> +				    "bnx2_alloc_bad_rbuf\n");
> +		return -ENOMEM;
> +	}
> +
>  	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
>  		BNX2_MISC_ENABLE_SET_BITS_RX_MBUF_ENABLE);
>  
> @@ -1178,6 +1185,7 @@
>  
>  		REG_WR_IND(bp, BNX2_RBUF_FW_BUF_FREE, val);
>  	}
> +	return 0;
>  }
>  
>  static void

memleak -- you need to free good_mbuf.

	Jeff
