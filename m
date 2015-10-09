From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] i40evf: fix 32 bit build warnings
Date: Fri, 9 Oct 2015 15:31:06 -0700
Message-ID: <20151009153106.000050f6@unknown>
References: <6607276.TY67sbLLqL@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <intel-wired-lan@lists.osuosl.org>,
	<kbuild-all@01.org>, Andrew Bowers <andrewx.bowers@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3579 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751176AbbJIWbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 18:31:23 -0400
In-Reply-To: <6607276.TY67sbLLqL@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Oct 2015 22:13:19 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> Jesse Brandeburg fixed a bug for 32-bit systems in the i40e driver
> in commit 9c70d7cebfec5 ("i40e: fix 32 bit build warnings"), but the
> same code still exists in the i40evf driver and causes compilation
> warnings in ARM and x86 allmodconfig:
> 
> drivers/net/ethernet/intel/i40evf/i40e_common.c:445:68: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
> drivers/net/ethernet/intel/i40evf/i40e_common.c:446:71: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
> 
> This applies the same fix by removing the broken code.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks for catching that, my mistake.
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

> It would probably be a good idea to merge some of the duplicate code into
> a library module that gets used by both drivers to avoid having to fix bugs
> twice in the future.

The library is a nice idea, but while much of the code is the same,
many things about interaction with it while running in the VF context
are different than when called in the PF context.

We will look closely at what we can commonize and at least move to
header files.

Thanks!
