From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8139 driver (8139too.c) TX Timeout doesn't allow interrupt handler to disable receive interrupts at high bi-directional traffic
Date: Fri, 10 Nov 2006 00:46:04 +0100
Message-ID: <20061109234604.GA17969@electric-eye.fr.zoreil.com>
References: <010C7BAE6783F34D9AC336EE5A01A08802BB30D7@dbde01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:61125 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1424286AbWKIXt3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:49:29 -0500
To: "Basheer, Mansoor Ahamed" <mansoor.ahamed@ti.com>
Content-Disposition: inline
In-Reply-To: <010C7BAE6783F34D9AC336EE5A01A08802BB30D7@dbde01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Basheer, Mansoor Ahamed <mansoor.ahamed@ti.com> :
[...]
> My understanding here is, on receive interrupt the ISR should disable
> the receive interrupt irrespective of the polling task's state (active
> or inactive).

Apparently it could happen even with 2.6.19-rc5, yes.

> I changed the code (as shown below) and it works perfectly. 

Afaics your change may disable the Rx irq right after the poll
routine enabled it again. It will not always work either.

The (slow) timeout watchdog could grab the poll handler and hack
the irq mask depending on whether poll was scheduled or not.

> Is this a known issue? If so, is there a fix already available?
> 
> Also, we get frequent TX timeouts during high rate of traffic. What
> could be the reason for this frequent TX timeouts?

No idea. Have you considered upgrading to a kernel which is not almost
2 years old ?

-- 
Ueimor
