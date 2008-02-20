From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 02/04] smc91x: introduce platform data flags
Date: Wed, 20 Feb 2008 10:58:06 -0500 (EST)
Message-ID: <alpine.LFD.1.00.0802201044270.2732@xanadu.home>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
 <20080220095802.22645.44691.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:10253 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbYBTP6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:58:07 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR003.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JWJ003SLOCUI180@VL-MO-MR003.ip.videotron.ca> for
 netdev@vger.kernel.org; Wed, 20 Feb 2008 10:58:06 -0500 (EST)
In-reply-to: <20080220095802.22645.44691.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008, Magnus Damm wrote:

> This patch introduces struct smc91x_platdata and modifies the driver so
> bus width is checked during run time using SMC_nBIT() instead of
> SMC_CAN_USE_nBIT.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> ---

NAK.

The SMC91C111 (for example) is often used on devices which have a CPU 
clock barely higher than the network throughput, hence it is crutial for 
those devices to have the most efficient access possible to the chip or 
performance will suffer.  This is the main reason behind the heavily 
macroized register access so things are always optimized for the data 
bus capabilities at compile time.

This patch introduces a runtimes test on lp->cfg.flags for every 
register access even on those platforms not using the platform data 
based bus configuration at all.

I think you should add a SMC_DYNAMIC_BUS_CONFIG and redefine SMC_nBITS() 
so they dereference cfg.flags only when it is defined.


Nicolas
