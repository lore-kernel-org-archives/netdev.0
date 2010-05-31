From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: change an error return code and some cleanup,
 take 4
Date: Mon, 31 May 2010 00:19:47 -0700 (PDT)
Message-ID: <20100531.001947.193703044.davem@davemloft.net>
References: <alpine.OSX.2.00.1004171258330.358@localhost>
	<20100421.163041.158540277.davem@davemloft.net>
	<alpine.OSX.2.00.1005290255580.691@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1005290255580.691@localhost>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Sat, 29 May 2010 03:29:01 +1000 (EST)

> @@ -662,7 +665,7 @@ static void mac8390_no_reset(struct net_
>  {
>  	ei_status.txing = 0;
>  	if (ei_debug > 1)
> -		pr_info("reset not supported\n");
> +		printk(KERN_DEBUG pr_fmt("reset not supported\n"));
>  	return;

Use pr_debug() or pr_devel().   Anything which explicitly codes
out a "printk(KERN_*" is suspect, we have interfaces for this. The
whole point of defining pr_fmt at the top of the driver is so
that in the driver, we use pr_foo() which includes the pr_fmt
string at the beginning.  If you bypass it you avoid the intended
effect of that pr_fmt define.

This is getting tiring Finn.

So we're already past 4 iterations of this silly simple patch, and I
want to remind you yet again what an incredibly hard time you gave Joe
Perches for his changes to this file which in the end were entirely
correct and well formed, and he got it right on his first attempt.

I advise you to think twice before snapping at another developer's
work in the future.
