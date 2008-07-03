From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Thu, 3 Jul 2008 14:04:36 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0807031353030.11033@blonde.site>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com> <486CC440.9030909@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from extu-mxob-1.symantec.com ([216.10.194.28]:58298 "EHLO
	extu-mxob-1.symantec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbYGCNEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 09:04:38 -0400
In-Reply-To: <486CC440.9030909@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Jul 2008, Jeff Garzik wrote:
> KOSAKI Motohiro wrote:
> > Hi Michael,
> > 
> > my server output following error message on 2.6.26-rc8-mm1.
> > Is this a bug?
> > 
> > ------------------------------------------------------------------
> > tg3.c:v3.93 (May 22, 2008)
> > GSI 72 (level, low) -> CPU 0 (0x0001) vector 51
> > tg3 0000:06:01.0: PCI INT A -> GSI 72 (level, low) -> IRQ 51
> > firmware: requesting tigon/tg3_tso.bin
> > tg3: Failed to load firmware "tigon/tg3_tso.bin"
> > tg3 0000:06:01.0: PCI INT A disabled
> > GSI 72 (level, low) -> CPU 0 (0x0001) vector 51 unregistered
> > tg3: probe of 0000:06:01.0 failed with error -2
> > GSI 73 (level, low) -> CPU 0 (0x0001) vector 51
> > tg3 0000:06:01.1: PCI INT B -> GSI 73 (level, low) -> IRQ 52
> > firmware: requesting tigon/tg3_tso.bin
> 
> This change did not come from the network developers or Broadcom, so someone
> else broke tg3 in -mm...

I think it's a consequence of not choosing CONFIG_FIRMWARE_IN_KERNEL=y.

That caught me out on PowerMac G5 trying mmotm yesterday, it just hung
for a few minutes in earlyish boot with a message about tg3_tso.bin,
and then proceeded to boot up but without the network.  I was unclear
whether I'd been stupid, or the FIRMWARE_IN_KERNEL Kconfigery was poor.

I avoid initrd, and have tigon3 built in, if that's of any relevance.

I wonder if that's Andrew's problem with 2.6.26-rc8-mm1 on his G5:
mine here boots up fine (now I know to CONFIG_FIRMWARE_IN_KERNEL=y).

Hugh
