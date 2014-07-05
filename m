From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] defxx: Fix issues with debug printk calls
Date: Sat, 05 Jul 2014 09:44:00 -0700
Message-ID: <1404578640.6384.49.camel@joe-AO725>
References: <alpine.LFD.2.11.1407051520310.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0109.hostedemail.com ([216.40.44.109]:42719 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751314AbaGEQoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 12:44:04 -0400
In-Reply-To: <alpine.LFD.2.11.1407051520310.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-07-05 at 15:28 +0100, Maciej W. Rozycki wrote:
[]
> +++ linux-20140623-swarm64-eb/drivers/net/fddi/defxx.h
> @@ -1693,7 +1693,7 @@ typedef union
>  /* Only execute special print call when debug driver was built */
>  
>  #ifdef DEFXX_DEBUG
> -#define DBG_printk(args...) printk(## args)
> +#define DBG_printk(args...) printk(args)
>  #else
>  #define DBG_printk(args...)
>  #endif

It'd be nicer to change this bit to

#ifdef DEFXX_DEBUG
#define DBG_printk(fmt, ...)					\
	printk(KERN_DEBUG fmt, ##__VA_ARGS__)
#else
#define DBG_printk(fmt, ...) 					\
	do (if (0) printk(KERN_DEBUG fmt, ##__VA_ARGS__); } while (0)
#endif

or just use pr_debug everywhere instead.
