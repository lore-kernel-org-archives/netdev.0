From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] NETDEBUG network triggerable messages in IPv6
Date: Sat, 10 Apr 2004 02:47:05 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040410.024705.97089877.yoshfuji@linux-ipv6.org>
References: <20040409182125.348fd6cd.ak@suse.de>
	<20040410.021840.113165465.yoshfuji@linux-ipv6.org>
	<20040409193123.63e4cdc7.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20040409193123.63e4cdc7.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040409193123.63e4cdc7.ak@suse.de> (at Fri, 9 Apr 2004 19:31:23 +0200), Andi Kleen <ak@suse.de> says:

> > I don't like the style; it is too ugly.
> > E.g. please do not put "if () ..." into the macro argument.
> 
> Ok, here is a new version that defines a new macro LIMIT_NETDEBUG that does the
> rate limit implicitely.
> -				if (net_ratelimit())
> -					printk(KERN_WARNING "overrun destopt\n"); 
> +				LIMIT_NETDEBUG(
> +					printk(KERN_WARNING "overrun destopt\n")); 

Grr...

I'd prefer:

  if (net_ratelimit())
    NETDEBUG_PRINTK("overrun destopt\n"..)
or

  NETDEBUG_PRINTK_LIMIT("overrun destopt\n"..)

(or something like this) much more.

--yoshfuji
