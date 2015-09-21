From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/7] 8139cp: Improve accuracy of cp_interrupt() return,
 to survive IRQ storms
Date: Mon, 21 Sep 2015 22:25:41 +0200
Message-ID: <20150921202541.GA4128@electric-eye.fr.zoreil.com>
References: <1442843991.7367.4.camel@infradead.org>
 <1442844109.7367.5.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40263 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755696AbbIUU0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 16:26:36 -0400
Content-Disposition: inline
In-Reply-To: <1442844109.7367.5.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
> From: David Woodhouse <David.Woodhouse@intel.com>
> 
> The TX timeout handling has been observed to trigger RX IRQ storms. And
> since cp_interrupt() just keeps saying that it handled the interrupt,
> the machine then dies. Fix the return value from cp_interrupt(), and
> the offending IRQ gets disabled and the machine survives.

I am not fond of the way it dissociates the hardware status word and the
software "handled" variable.

What you are describing - RX IRQ storms - looks like a problem between
the irq and poll handlers. That's where I expect the problem to be solved.
Sprinkling "handled" operations does not make me terribly confortable,
especially as I'd happily trade the old-style part irq, part napi
processing for a plain napi processing (I can get over it though :o) ).

Once the code is past the "if (!status || (status == 0xFFFF))" test -
or whatever test against some mask - I don't see why the driver could
refuse to take ownership of the irq.

-- 
Ueimor
