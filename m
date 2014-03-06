From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 12/13] r8152: add additional parameter for
 non x86 platform
Date: Thu, 06 Mar 2014 00:05:18 -0500 (EST)
Message-ID: <20140306.000518.449808421540608140.davem@davemloft.net>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	<1394002168-3193-1-git-send-email-hayeswang@realtek.com>
	<1394002168-3193-13-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394002168-3193-13-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 5 Mar 2014 14:49:27 +0800

> Add additional parameter for non x86 platform for better throughput.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

This commit message tells me absolutely nothing.

First of all, it doesn't say what the issue is, why is the chip
slower on non-x86 platforms with the current way it is programmed?

And in particular, which non-x86 platform?  You can't possibly mean
all of them.

I can almost guarentee if you actually explain the issue, I'm going
to tell you to use a more meaningful test for the condition or
property an architecture has which makes the alternative setting
more desirable.

>  /* USB_RX_EARLY_AGG */
> -#define EARLY_AGG_SUPPER	0x0e832981
> +#if defined(__i386__) || defined(__x86_64__)
> +	#define EARLY_AGG_SUPPER	0x0e832981
> +#else
> +	#define EARLY_AGG_SUPPER	0x0e835000
> +#endif

And this value is completely magic, you must document what this
register value means.

I find this patch series extremely frustrating.

You are combining so many things all at once, so if one aspect
requires changes or to be removed, it invalidates the rest of
the series and you have to respin it all over again.

Why don't you re-submit this in pieces?  First the cleanups
(first three patches) would be one series.

Once I apply that, perhaps submit the locking changes and
tso/checksum support.

Then finally, after I apply that, submit the tweaks at the end.

Thank you.
