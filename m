From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [Patch]net/xfrm/xfrm_policy.c: replace timer with delayed_work
Date: Mon, 28 Apr 2008 22:53:12 +0800 (CST)
Message-ID: <20080428.225312.58450957.xiyou.wangcong@gmail.com>
References: <20080216.235534.237382205.xiyou.wangcong@gmail.com>
	<20080427011809.GA662@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net, akpm@osdl.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:20724 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932830AbYD1OyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 10:54:11 -0400
Received: by wf-out-1314.google.com with SMTP id 28so4054937wff.4
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 07:54:10 -0700 (PDT)
In-Reply-To: <20080427011809.GA662@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 27 Apr 2008 09:18:09 +0800
> On Sat, Feb 16, 2008 at 11:55:34PM +0800, WANG Cong wrote:
> > 
> > As suggested by Herbert, using workqueue is better than timer
> > for net/xfrm/xfrm_policy.c, so replace them with delayed_work.
> > 
> > Note that, this patch is not fully tested, just compile and
> > run as a whole on an Intel Core Duo matchine. So should be
> > in -mm first.
> > 
> > Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Cc: David Miller <davem@davemloft.net>
> 
> Sorry for the extremely long delay, but I've finally made it
> to this email in my backlog :)
> 
> The patch looks OK except for one thing, the read-write spin
> lock needs to disable BH now that it's moved to process context.
> Otherwise we'll get dead-locks with the softirq path taking the
> same lock.

Do you mean ->lock of struct xfrm_policy?
OK. I will recook these two patches soon.

Thanks for review.
