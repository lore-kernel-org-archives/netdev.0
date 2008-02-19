From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Mon, 18 Feb 2008 17:03:32 -0800
Message-ID: <1203383012.7181.102.camel@localhost>
References: <20080218.125525.192686382.davem@davemloft.net>
	 <47B9F5E7.3020905@trash.net> <20080218.164305.67586867.davem@davemloft.net>
	 <20080218.165036.218650084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080218.165036.218650084.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-02-18 at 16:50 -0800, David Miller wrote:
> Actually it seems the 'pure' attribute is more important
> here.  Although it's not semantically a perfect match,
> what we need to tell the compiler is basically that:
> 
> 1) the return value depends upon the inputs
> 2) if the input is not used, it's safe to avoid the call
> 
> and 'pure' accomplishes that without any unwanted side-effects.
> 
> I think this will not result in any unwanted over-optimization.
> Because if the inputs change in any way GCC has to emit the
> call.
> 
> Any objections?

Does this need to be done for all function calls
declared with __attribute__((format(printf, x, y)))
{
return 0;
}

ie: pr_debug, dev_dbg, dev_vdbg?

Perhaps it's more sensible to go back to

#ifdef DEBUG
#define pr_debug(fmt, arg...) do {} while (0)
#endif

and give up the printf argument verification
