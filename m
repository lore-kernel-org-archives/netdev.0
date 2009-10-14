From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2] net/fec_mpc52xx: Fix kernel panic on FEC error
Date: Wed, 14 Oct 2009 21:11:03 +0200
Message-ID: <4AD62247.4020102@grandegger.com>
References: <20091014174224.29221.18830.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	davem@davemloft.net, John Bonesio <bones@secretlab.ca>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:50889 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbZJNTMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 15:12:19 -0400
In-Reply-To: <20091014174224.29221.18830.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Likely wrote:
> From: John Bonesio <bones@secretlab.ca>
> 
> The MDIO bus cannot be accessed at interrupt context, but on an FEC
> error, the fec_mpc52xx driver reset function also tries to reset the
> PHY.  Since the error is detected at IRQ context, and the PHY functions
> try to sleep, the kernel ends up panicking.
> 
> Resetting the PHY on an FEC error isn't even necessary.  This patch
> solves the problem by removing the PHY reset entirely.

There is also no need to free and re-allocate the RX buffers in
mpc52xx_fec_reset().

Wolfgang.
