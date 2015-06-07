From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH] cosa: use msecs_to_jiffies for conversions
Date: Sun, 7 Jun 2015 10:25:58 +0200
Message-ID: <20150607082558.GA9670@opentech.at>
References: <1433577111-7404-1-git-send-email-hofrat@osadl.org> <20150607.001800.854104281240414676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hofrat@osadl.org, kas@fi.muni.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hofr.at ([212.69.189.236]:47744 "EHLO mail.hofr.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155AbbFGI0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jun 2015 04:26:00 -0400
Content-Disposition: inline
In-Reply-To: <20150607.001800.854104281240414676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 07 Jun 2015, David Miller wrote:

> From: Nicholas Mc Guire <hofrat@osadl.org>
> Date: Sat,  6 Jun 2015 09:51:51 +0200
> 
> > @@ -517,7 +517,7 @@ static int cosa_probe(int base, int irq, int dma)
> >  		 */
> >  		set_current_state(TASK_INTERRUPTIBLE);
> >  		cosa_putstatus(cosa, SR_TX_INT_ENA);
> > -		schedule_timeout(30);
> > +		schedule_timeout(msecs_to_jiffies(300));
> >  		irq = probe_irq_off(irqs);
> >  		/* Disable all IRQs from the card */
> >  		cosa_putstatus(cosa, 0);
> 
> You are making these transformations completely inconsistently.
> 
> You're converting it to msecs in some patches and here you are doing
> something else.
>

As noted in the cosa case the code predated configurable HZ so the
30 was definitely assuming HZ=100 and therefor it should probably be 300
now - I do not think that is inconsisten and it was explained in the
patch. I only can make the HZ=100 assumption if the code predates 
configurable HZ otherwise I leave it at the nominal value and put a note
in that it may be a significant change and needs review.

What alternative would you suggest ?
 
> Please do _all_ of these transformations consistently and in a way
> that minimizes the chances of breaking things.
> 
> And the only way to do that is to strictly convert these cases to
> whatever it works out to when HZ=100 since that is strictly the
> environment all of this old code was written in.
>
for the dscc4 case Im not sure - that seems to have gone in in 2.4
and that had HZ configurable. The cosa case was checked 
again 2.2.26 (no config HZ) and the timeout there was 30 -> 300ms.

I think that this is consistent with respect to the limited available
information of the timeout unit in the code.

thx!
hofrat
