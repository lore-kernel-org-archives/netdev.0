From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] ibm_newemac: PowerPC 440GX EMAC PHY clock
 workaround
Date: Fri, 11 Apr 2008 09:24:17 -0500
Message-ID: <20080411092417.57825115@zod.rchland.ibm.com>
References: <20080327144044.GA8831@ru.mvista.com>
	<47EDA6F1.9080206@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Valentine Barshak <vbarshak@ru.mvista.com>,
	linuxppc-dev@ozlabs.org, benh@kernel.crashing.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:58545 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188AbYDKO0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 10:26:41 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3BEQZLM024312
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 10:26:35 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3BEQZ5m201752
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 08:26:35 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3BEQYud020068
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 08:26:35 -0600
In-Reply-To: <47EDA6F1.9080206@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Mar 2008 22:18:25 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Valentine Barshak wrote:
> > The PowerPC 440GX Taishan board fails to reset EMAC3 (reset timeout error)
> > if there's no link. Because of that it fails to find PHY chip. The older ibm_emac
> > driver had a workaround for that: the EMAC_CLK_INTERNAL/EMAC_CLK_EXTERNAL macros,
> > which toggle the Ethernet Clock Select bit in the SDR0_MFR register. This patch
> > does the same for "ibm,emac-440gx" compatible chips. The workaround forces
> > clock on -all- EMACs, so we select clock under global emac_phy_map_lock.
> > 
> > Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> > ---
> >  drivers/net/ibm_newemac/core.c |   16 +++++++++++++++-
> >  drivers/net/ibm_newemac/core.h |    8 ++++++--
> >  2 files changed, 21 insertions(+), 3 deletions(-)
> 
> is this for 2.6.25-rc?

Jeff, can I get an ack from you on this patch, and patch 2 in this
set?  They depend on a patch in my tree and I'd like to include them in
my next push to Paul for 2.6.26.

josh
