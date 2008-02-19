From: Philip Craig <philipc-XXXsiaCtIV5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Tue, 19 Feb 2008 11:30:25 +1000
Message-ID: <47BA3131.3080907@snapgear.com>
References: <20080218.125525.192686382.davem@davemloft.net>	 <47B9F5E7.3020905@trash.net> <20080218.164305.67586867.davem@davemloft.net>	 <20080218.165036.218650084.davem@davemloft.net> <1203383012.7181.102.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1203383012.7181.102.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> Perhaps it's more sensible to go back to
> 
> #ifdef DEBUG
> #define pr_debug(fmt, arg...) do {} while (0)
> #endif
> 
> and give up the printf argument verification

I think argument verification is important.   Can you keep it
like this:

#ifdef DEBUG
#define pr_debug(fmt, arg...) \
	do { \
		if (0) \
			printk(KERN_DEBUG fmt, ##arg); \
	} while (0)
#endif

We still lose the return value though, I'm not sure how to keep that
safely in macros.

But does anything rely on the side effects already?  This would
introduce bugs if so.
