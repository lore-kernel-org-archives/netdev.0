From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 01/15] drivers/net: delete 486 Apricot support
Date: Tue, 22 Jan 2013 10:51:25 -0500
Message-ID: <20130122155125.GA19259@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
 <1358819182-28032-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45424 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab3AVPvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 10:51:16 -0500
Content-Disposition: inline
In-Reply-To: <1358819182-28032-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[PATCH net-next 01/15] drivers/net: delete 486 Apricot support] On 21/01/2013 (Mon 20:46) Paul Gortmaker wrote:

[...]

>  
> -#elif defined(ENABLE_APRICOT)
> -
> -	{
> -		u32 scp = virt_to_bus(&lp->scp);
> -
> -		/* change the scp address */
> -		outw(0, ioaddr);
> -		outw(0, ioaddr);
> -		outb(4, ioaddr + 0xf);
> -		outw(scp | 2, ioaddr);
> -		outw(scp >> 16, ioaddr);
> -	}
> -#endif
> -

I deleted one too many lines here.  That last #endif needs
to stay as the parent #if still remains.  Fengguang's 0-day
testing found it in an m68k allyesconfig build.

I've folded this in, build tested for m68k locally, and done
a forced update on my legacy-isa-delete branch.

Paul.
--
