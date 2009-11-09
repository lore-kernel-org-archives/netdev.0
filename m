From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH RFC] gianfar: Do not call skb recycling with disabled
 IRQs
Date: Mon, 9 Nov 2009 16:41:34 +0300
Message-ID: <20091109134134.GB26965@oksana.dev.rtsoft.ru>
References: <E1N63WM-0003xK-PN@jdl.com>
 <E1N64UY-00049g-Hb@jdl.com>
 <20091105165738.GA31923@oksana.dev.rtsoft.ru>
 <20091108.010848.116517157.davem@davemloft.net>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jdl@jdl.com, linuxppc-dev@ozlabs.org, jason.wessel@windriver.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	buytenh@wantstofly.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:14981 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755898AbZKINl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 08:41:29 -0500
Content-Disposition: inline
In-Reply-To: <20091108.010848.116517157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 08, 2009 at 01:08:48AM -0800, David Miller wrote:
> From: Anton Vorontsov <avorontsov@ru.mvista.com>
> Date: Thu, 5 Nov 2009 19:57:38 +0300
> 
> > But that basically means that with skb recycling we can't safely
> > use KGDBoE, though we can add something like this:
> 
> Please stop adding special logic only to your driver to handle these
> things.
> 
> Either it's a non-issue, or it's going to potentially be an issue for
> everyone using skb_recycle_check() in a NAPI driver, right?
> 
> So why not add the "in_interrupt()" or whatever check to
> skb_recycle_check() and if the context is unsuitable return false (0)
> ok?

I think the check is needed, yes. But if we add just that check,
then we'll never do skb recycling in the tx path (since gianfar
always grabs irqsave spinlock during tx ring cleanup, so the check
will always return false).

So we must add the check to keep polling with disabled IRQs safe,
but we also should get rid of irqsave spinlock in the gianfar
driver (to make the skb recycling actually work in most cases).

Thanks!

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
