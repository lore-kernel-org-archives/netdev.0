From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: add IntMode module parameter
Date: Sun, 18 Apr 2010 22:09:31 -0700 (PDT)
Message-ID: <20100418.220931.39174434.davem@davemloft.net>
References: <20100419050315.24758.62479.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	nicholasx.d.nunley@intel.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47476
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751095Ab0DSFJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 01:09:26 -0400
In-Reply-To: <20100419050315.24758.62479.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 18 Apr 2010 22:03:59 -0700

> This patch adds the IntMode module parameter to ixgbe to allow
> user selection of interrupt mode (MSI-X, MSI, legacy) on driver
> load.  To work around the errata described above, ixgbe needs to
> be able to disable MSI-X for affected configurations.

This is not how we handle situations like this.

Here is one acceptable way to handle this:

Turn MSI/MSI-X off for every system that uses this PCI-E
complex chipset.  Add a whitelist that allows enabling.

Here is another:

Turn MSI/MSI-X on by default and have blacklists.

Anything that requires unusual user interactions, such as specifying
special module parameters, for correct operations is absolutely
unacceptable.

I don't want to hear how difficult it is to determine whether a
system will hit this bug or not.  If it's hard, just turn MSI
off unconditionally with this chipset until you can detect things
properly.
