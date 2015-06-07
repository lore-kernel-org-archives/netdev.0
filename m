From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cosa: use msecs_to_jiffies for conversions
Date: Sun, 07 Jun 2015 00:18:00 -0700 (PDT)
Message-ID: <20150607.001800.854104281240414676.davem@davemloft.net>
References: <1433577111-7404-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kas@fi.muni.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbbFGHSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 03:18:01 -0400
In-Reply-To: <1433577111-7404-1-git-send-email-hofrat@osadl.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Sat,  6 Jun 2015 09:51:51 +0200

> @@ -517,7 +517,7 @@ static int cosa_probe(int base, int irq, int dma)
>  		 */
>  		set_current_state(TASK_INTERRUPTIBLE);
>  		cosa_putstatus(cosa, SR_TX_INT_ENA);
> -		schedule_timeout(30);
> +		schedule_timeout(msecs_to_jiffies(300));
>  		irq = probe_irq_off(irqs);
>  		/* Disable all IRQs from the card */
>  		cosa_putstatus(cosa, 0);

You are making these transformations completely inconsistently.

You're converting it to msecs in some patches and here you are doing
something else.

Please do _all_ of these transformations consistently and in a way
that minimizes the chances of breaking things.

And the only way to do that is to strictly convert these cases to
whatever it works out to when HZ=100 since that is strictly the
environment all of this old code was written in.

Thank you.
