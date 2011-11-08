From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/5] net/sunrpc: use kstrtoul, etc
Date: Tue, 8 Nov 2011 22:38:18 +0300
Message-ID: <20111108193817.GA3453@p183.telecom.by>
References: <1320586010-21931-1-git-send-email-julia@diku.dk>
 <1320586010-21931-3-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1320586010-21931-3-git-send-email-julia-dAYI7NvHqcQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 06, 2011 at 02:26:47PM +0100, Julia Lawall wrote:
> @@
> expression a,b;
> {int,long} *c;
> @@
> 
> -strict_strtoul
> +kstrtoul

No, no, no!

In every case see the type or real data and use appropriate function.
kstrtou8() for ports.
This program creates lots of bogus patches in this case.

> --- a/net/sunrpc/addr.c
> +++ b/net/sunrpc/addr.c
> @@ -322,7 +322,7 @@ size_t rpc_uaddr2sockaddr(const char *ua
>  	c = strrchr(buf, '.');
>  	if (unlikely(c == NULL))
>  		return 0;
> -	if (unlikely(strict_strtoul(c + 1, 10, &portlo) != 0))
> +	if (unlikely(kstrtoul(c + 1, 10, &portlo) != 0))
>  		return 0;
>  	if (unlikely(portlo > 255))
>  		return 0;
> @@ -331,7 +331,7 @@ size_t rpc_uaddr2sockaddr(const char *ua
>  	c = strrchr(buf, '.');
>  	if (unlikely(c == NULL))
>  		return 0;
> -	if (unlikely(strict_strtoul(c + 1, 10, &porthi) != 0))
> +	if (unlikely(kstrtoul(c + 1, 10, &porthi) != 0))
>  		return 0;
>  	if (unlikely(porthi > 255))
>  		return 0;
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
