From: Lucas Nussbaum <lucas.nussbaum@imag.fr>
Subject: Re: [BUG] tg3 cannot do PXE (loses MAC address) after soft reboot
Date: Thu, 13 Sep 2007 17:41:10 +0200
Message-ID: <20070913154110.GA25781@xanadu.blop.info>
References: <20070913083918.GA5386@xanadu.blop.info> <1551EAE59135BE47B544934E30FC4FC002AABA5B@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([80.248.208.235]:39395 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752760AbXIMPle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 11:41:34 -0400
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABA5B@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/09/07 at 08:15 -0700, Michael Chan wrote:
> Lucas Nussbaum wrote:
> 
> > This used to work, and broke between 2.6.16 and 2.6.17. Using 
> > git bissect,
> > I could trace this back to that commit:
> > commit bc1c756741b065cfebf850e4164c0e2aae9d527f
> > Author: Michael Chan <mchan@broadcom.com>
> > Date:   Mon Mar 20 17:48:03 2006 -0800
> >     [TG3]: Support shutdown WoL.
> 
> This may be caused by bugs in early versions of bootcode or
> PXE code.  When tg3 powers down the PHY during shutdown, the
> MAC address will become zero in the MAC address register.  The
> PXE code or bootcode needs to fetch the MAC address again from
> The NVRAM.
> 
> Can you also send me ethtool -i eth0 which will provide the
> bootcode version?  What machine are you using?  Thanks.

# ethtool -i eth0
driver: tg3
version: 3.65
firmware-version: 5703-v2.21a
bus-info: 0000:02:02.0

What do you mean by "what machine" ? The systems are Dell PowerEdge
1600SC, but the NICs were bought separately AFAIK.
-- 
| Lucas Nussbaum                        PhD student |
| lucas.nussbaum@imag.fr        LIG / Projet MESCAL |
| jabber: lucas@nussbaum.fr    +33 (0)6 64 71 41 65 |
| homepage:        http://www-id.imag.fr/~nussbaum/ |
