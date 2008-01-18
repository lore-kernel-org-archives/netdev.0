From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Fri, 18 Jan 2008 05:37:12 -0800 (PST)
Message-ID: <20080118.053712.195382841.davem@davemloft.net>
References: <18318.14810.877279.41815@robur.slu.se>
	<20080118.041144.81957249.davem@davemloft.net>
	<18320.41737.651384.808195@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: elendil@planet.nl, jesse.brandeburg@intel.com,
	slavon@bigtelecom.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48170
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761366AbYARNhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 08:37:11 -0500
In-Reply-To: <18320.41737.651384.808195@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Fri, 18 Jan 2008 14:00:57 +0100

>  I don't understand the idea with semaphore for enabling/disabling 
>  irq's either the overall logic must safer/better without it.  

They must have had code paths where they didn't know if IRQs were
enabled or not already, so they tried to create something which
approximates the:

	local_irq_save(flags);
	local_irq_restore(flags);

constructs we have for CPU interrupts, so they could go:

	e1000_irq_disable();
	/* ... */
	e1000_irq_enable();

and this would work even if the caller was running
with e1000 interrupts disabled already.

Or, something like that... it is indeed confusing.

Anyways, yes it's totally bogus and should be removed.
