From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH for/net-next 2/8] net/mlx5: Mellanox Connect-IB, core
 driver part 2/3
Date: Fri, 28 Jun 2013 21:08:55 -0700 (PDT)
Message-ID: <20130628.210855.431269923795010173.davem@davemloft.net>
References: <1372256537-21328-1-git-send-email-ogerlitz@mellanox.com>
	<1372256537-21328-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372256537-21328-3-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Wed, 26 Jun 2013 17:22:11 +0300

> +		eqe->owner = 0x55;

Magic constant.  If this is how you will represent "Invalid Owner",
then make a macro for this value 0x55 expressing that.

> +	switch (synd) {
> +	case 0x1:

Please make descriptive macros instead of using magic constants.

> +#if defined(__LITTLE_ENDIAN)
> +	he_in.he = 0x0;
> +#elif defined(__BIG_ENDIAN)
> +	he_in.he = 0x80;
> +#else
> +#error Host endianness not defined
> +#endif

This endiannes bit needs a define, rather than just using a magic
constant.  And where you define this in a header file, you can do
the CPP ifdefs, rather than here.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
