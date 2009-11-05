From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH RFC] gianfar: Do not call skb recycling with disabled
 IRQs
Date: Thu, 5 Nov 2009 20:34:09 +0300
Message-ID: <20091105173409.GA24801@oksana.dev.rtsoft.ru>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru>
 <E1N62ti-0003iS-K2@jdl.com>
 <20091105142028.GB17171@oksana.dev.rtsoft.ru>
 <E1N63WM-0003xK-PN@jdl.com>
 <E1N64UY-00049g-Hb@jdl.com>
 <20091105165738.GA31923@oksana.dev.rtsoft.ru>
 <9F4C7D19E8361D4C94921B95BE08B81B950713@zin33exm22.fsl.freescale.net>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jon Loeliger <jdl@jdl.com>, linuxppc-dev@ozlabs.org,
	Jason Wessel <jason.wessel@windriver.com>,
	Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:3277 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751991AbZKEReI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 12:34:08 -0500
Content-Disposition: inline
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B950713@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 05, 2009 at 10:53:08PM +0530, Kumar Gopalpet-B05799 wrote:
[...]
> >(spin_trylock_irqsave(&tx_queue->txlock, flags)) {
> >-				tx_cleaned += 
> >gfar_clean_tx_ring(tx_queue);
> >-				
> >spin_unlock_irqrestore(&tx_queue->txlock,
> >-							flags);
> >-			}
> >+			netif_tx_lock_bh(priv->ndev);
> 
> Will this not lead to locking all the tx queues even though at this
> point we are working on a "particular queue" ?

Yeah, per-txq locking would be better (or not.. I need to netperf
it).

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
