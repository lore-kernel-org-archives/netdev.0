From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch v3] fix stack overflow in pktgen_if_write()
Date: Fri, 29 Oct 2010 01:11:57 +0200
Message-ID: <87lj5hud36.fsf@basil.nowhere.org>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
	<20101027221234.GN6062@bicker> <20101027224302.GQ6062@bicker>
	<20101027230657.GT16803@ksplice.com> <20101028060529.GX6062@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nelson Elhage <nelhage@ksplice.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:45497 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758369Ab0J1XME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 19:12:04 -0400
In-Reply-To: <20101028060529.GX6062@bicker> (Dan Carpenter's message of "Thu,
	28 Oct 2010 08:05:29 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <error27@gmail.com> writes:

> Reported-by: Nelson Elhage <nelhage@ksplice.com>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> v3:  just use kmalloc()
>
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 2c0df0f..c8d3620 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -887,12 +887,17 @@ static ssize_t pktgen_if_write(struct file *file,
>  	i += len;
>  
>  	if (debug) {
> -		char tb[count + 1];
> +		char *tb;
> +
> +		tb = kmalloc(count + 1, GFP_KERNEL);


This is still trivially exploitable (for root) -- think what happens
when count is near ULONG_MAX

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
