From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: fix pr_info() calls and change return code
Date: Thu, 15 Apr 2010 22:53:43 -0700 (PDT)
Message-ID: <20100415.225343.266704449.davem@davemloft.net>
References: <20100415.200113.215578006.davem@davemloft.net>
	<alpine.OSX.2.00.1004161323340.271@localhost>
	<alpine.OSX.2.00.1004161403160.271@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1004161403160.271@localhost>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Fri, 16 Apr 2010 14:21:00 +1000 (EST)

>  
> @@ -668,11 +668,11 @@
>  {
>  	unsigned char *target = nubus_slot_addr(IRQ2SLOT(dev->irq));
>  	if (ei_debug > 1)
> -		pr_info("Need to reset the NS8390 t=%lu...", jiffies);
> +		printk(KERN_DEBUG "Need to reset the NS8390 t=%lu...", jiffies);
>  	ei_status.txing = 0;
>  	target[0xC0000] = 0;
>  	if (ei_debug > 1)
> -		pr_cont("reset complete\n");
> +		printk(KERN_CONT "reset complete\n");
>  	return;

You're missing the whole point of using pr_info() et al.  in that it
includes the bits we define for pr_fmt at the top of the file.

Also, you write absolutely no commit log message entry for your
change explaining why you're doing the things you are doing.

And finally you are doing two completely unrelated things at one
(changing error return values and changing log message levels).
