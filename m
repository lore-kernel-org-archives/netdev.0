From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.26-rc9] r8169: Avoid thrashing PCI conf space on
	RTL_GIGA_MAC_VER_20.
Date: Fri, 11 Jul 2008 00:17:29 +0200
Message-ID: <20080710221729.GB18477@electric-eye.fr.zoreil.com>
References: <48760F22.8040208@ingate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marcus Sundberg <marcus@ingate.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:53612 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbYGJWRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:17:36 -0400
Content-Disposition: inline
In-Reply-To: <48760F22.8040208@ingate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcus Sundberg <marcus@ingate.com> :
> The magic write to register 0x82 will often cause PCI config space on
> my 8168 (PCI ID 10ec:8168, revision 2. mounted in an LG P300 laptop)
> to be filled with ones during driver load, and thus breaking NIC
> operation until reboot. If it does not happen on first driver load it
> can easily be reproduced by unloading and loading the driver a few
> times.

I have added it at the root of the 'r8169' branch in repository:

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169

The branch is described below (on top of davem's 'next' branch).

The whole serie is available as a patck-kit on top of 2.6.26-rc9 at:

http://userweb.kernel.org/~romieu/r8169/2.6.26-rc9/20080710/ 


Diffstat
--------

 drivers/net/r8169.c |  496 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 470 insertions(+), 26 deletions(-)

Shortlog
--------

Francois Romieu (12):
      r8169: update phy init parameters
      r8169: new phy init parameters for the 8168b
      r8169: shuffle some registers handling around (8168 operation only)
      r8169: add 8168 registers description
      r8169: make room for more specific 8168 hardware start procedure
      r8169: Tx performance tweak
      r8169: sync existing 8168 device hardware start sequences with vendor driver
      r8169: add a new 8168 flavor
      r8169: add a new 8168 flavor (bis)
      r8169: add a new 8168 flavor (ter)
      r8169: change default behavior for mildly identified 8168c chipsets
      r8169: use pci_find_capability for the PCI-E features

Marcus Sundberg (1):
      r8169: avoid thrashing PCI conf space above RTL_GIGA_MAC_VER_06

-- 
Ueimor
