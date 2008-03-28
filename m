From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4] drivers/atm/firestream.c: suppress uninitialized
 var warning
Date: Fri, 28 Mar 2008 16:54:37 -0700
Message-ID: <20080328165437.bfd7726c.akpm@linux-foundation.org>
References: <200803282137.m2SLbTJl011626@imap1.linux-foundation.org>
	<20080328.162017.169462194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil, jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39903 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750793AbYC1XzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:55:06 -0400
In-Reply-To: <20080328.162017.169462194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Mar 2008 16:20:17 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Fri, 28 Mar 2008 14:37:29 -0700
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > drivers/atm/firestream.c: In function 'fs_open':
> > drivers/atm/firestream.c:870: warning: 'tmc0' may be used uninitialized in this function
> > 
> > I have confirmed that this is a false positive.
> > 
> > Cc: David S. Miller <davem@davemloft.net>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Cc: chas williams <chas@cmf.nrl.navy.mil>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Andrew, I'm not applying patches that use that sinful
> uninitialized_var() thing.

Your call, but it isn't sinful.  It has documentary value - it tells the
reader "we don't really need to do this, but gcc isn't smart enough".

> I'll apply the following instead.
> 
> commit d41a95e04ae80b77ddc186d0d97e6b439684adb8
> Author: David S. Miller <davem@davemloft.net>
> Date:   Fri Mar 28 16:19:26 2008 -0700
> 
>     [ATM] firestream: Fix uninitialized var warning.
>     
>     All code paths set tmc0 in some way, but GCC can't
>     see that for some reason.  Explicitly initialize
>     to zero.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
> index 47c57a4..98099f5 100644
> --- a/drivers/atm/firestream.c
> +++ b/drivers/atm/firestream.c
> @@ -978,6 +978,7 @@ static int fs_open(struct atm_vcc *atm_vcc)
>  		/* Docs are vague about this atm_hdr field. By the way, the FS
>  		 * chip makes odd errors if lower bits are set.... -- REW */
>  		tc->atm_hdr =  (vpi << 20) | (vci << 4); 
> +		tmc0 = 0;
>  		{
>  			int pcr = atm_pcr_goal (txtp);

Whereas the reader doesn't know why that unneeded initialisation is there.

And it generates additional, unneeded code.
