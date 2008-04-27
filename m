From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch]net/xfrm/xfrm_policy.c: replace timer with delayed_work
Date: Sun, 27 Apr 2008 09:18:09 +0800
Message-ID: <20080427011809.GA662@gondor.apana.org.au>
References: <20080216.235534.237382205.xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33893 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756883AbYD0BSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 21:18:18 -0400
Content-Disposition: inline
In-Reply-To: <20080216.235534.237382205.xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 16, 2008 at 11:55:34PM +0800, WANG Cong wrote:
> 
> As suggested by Herbert, using workqueue is better than timer
> for net/xfrm/xfrm_policy.c, so replace them with delayed_work.
> 
> Note that, this patch is not fully tested, just compile and
> run as a whole on an Intel Core Duo matchine. So should be
> in -mm first.
> 
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: David Miller <davem@davemloft.net>

Sorry for the extremely long delay, but I've finally made it
to this email in my backlog :)

The patch looks OK except for one thing, the read-write spin
lock needs to disable BH now that it's moved to process context.
Otherwise we'll get dead-locks with the softirq path taking the
same lock.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
