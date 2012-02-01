From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] bna: Implement ethtool flash_device entry point.
Date: Wed, 1 Feb 2012 22:17:50 +0000
Message-ID: <1328134670.2541.19.camel@bwh-desktop>
References: <1328054801-11322-1-git-send-email-kgudipat@brocade.com>
	 <1328123687.2541.10.camel@bwh-desktop>
	 <B5EE62D80D50B84BB9E5174F7FCCE80A260325B6E1@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>
To: Krishna Gudipati <kgudipat@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8839 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757612Ab2BAWRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 17:17:55 -0500
In-Reply-To: <B5EE62D80D50B84BB9E5174F7FCCE80A260325B6E1@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-01 at 14:10 -0800, Krishna Gudipati wrote:
> Thanks Ben for the review.
> 
> I am making the changes as per the review comments to return proper error code.
> 
> > +	init_completion(&fcomp.comp);
> > +	spin_lock_irqsave(&bnad->bna_lock, flags);
> 
> No need to save flags, this is not called in IRQ context!
> 
> [Krishna]: bna_lock is used in Interrupt context as well, by using spin_lock_irq instead of
> 	     spin_lock_irqsave() - we will lose the state of the interrupts & will
> 	     unconditionally enable interrupts. We plan to stay with using spin_lock_irqsave()
> 	     as it's safe.

bnad_flash_device() will be called in process context, therefore it is
correct to unconditionally enable interrupts.  It is safe but odd to use
spin_lock_irqsave()/spin_lock_irqrestore() in such a function.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
