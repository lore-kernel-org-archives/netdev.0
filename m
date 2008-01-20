From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Sun, 20 Jan 2008 01:20:11 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52043A156F@orsmsx418.amr.corp.intel.com>
References: <18318.14810.877279.41815@robur.slu.se><20080118.041144.81957249.davem@davemloft.net><18320.41737.651384.808195@robur.slu.se> <20080118.053712.195382841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <elendil@planet.nl>, <slavon@bigtelecom.ru>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14478 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbYATJUZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 04:20:25 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080118.053712.195382841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Robert Olsson <Robert.Olsson@data.slu.se>
> Date: Fri, 18 Jan 2008 14:00:57 +0100
> 
>>  I don't understand the idea with semaphore for enabling/disabling
>>  irq's either the overall logic must safer/better without it.
> 
> They must have had code paths where they didn't know if IRQs were
> enabled or not already, so they tried to create something which
> approximates the:
> 
> 	local_irq_save(flags);
> 	local_irq_restore(flags);
> 
> constructs we have for CPU interrupts, so they could go:
> 
> 	e1000_irq_disable();
> 	/* ... */
> 	e1000_irq_enable();
> 
> and this would work even if the caller was running
> with e1000 interrupts disabled already.
> 
> Or, something like that... it is indeed confusing.
> 
> Anyways, yes it's totally bogus and should be removed.

I agree, bogus, and in fact I've already removed it from our development
version of ixgbe.  Right now I wanted to report I can't remove e1000 at
all on 2.6.24-rc8+git

I continually get the
 kernel: unregister_netdevice: waiting for eth2 to become free. Usage
count = 1

Where 2.6.24-rc5 e1000 is okay still.  Seems like maybe we are still
missing a netif_rx_complete or a napi_disable somewhere.

I don't think this problem has anything to do with the irq_sem right
now.  Something is still badly broken.  I am just using the interface
regularly (no heavy load) and I can't unload the module.

Jesse
