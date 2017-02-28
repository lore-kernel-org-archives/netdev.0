From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [patch] net/mlx4: && vs & typo
Date: Tue, 28 Feb 2017 14:23:50 -0800
Message-ID: <1488320630.25838.39.camel@perches.com>
References: <20170228120215.GA27947@mwanda>
         <1488296129.3056.1.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1488296129.3056.1.camel-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-02-28 at 15:35 +0000, Bart Van Assche wrote:
> On Tue, 2017-02-28 at 15:02 +0300, Dan Carpenter wrote:
> > Bitwise & was obviously intended here.
[]
> > diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h
[]
> > @@ -109,7 +109,7 @@ static inline void 	(u8 *addr, u64 mac)
> >  	int i;
> >  
> >  	for (i = ETH_ALEN; i > 0; i--) {
> > -		addr[i - 1] = mac && 0xFF;
> > +		addr[i - 1] = mac & 0xFF;
> >  		mac >>= 8;
> >  	}
> >  }
> 
> Is this the only place where such a loop occurs?

Seems to be.

> Should a put_unaligned_be48()
> function be introduced?

Why?  This is used exactly once.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
