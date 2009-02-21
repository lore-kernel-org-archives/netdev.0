From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] ixgbe: fix Si errata - require L0's
 disable on upstream device
Date: Sat, 21 Feb 2009 15:42:18 -0800 (PST)
Message-ID: <20090221.154218.174943978.davem@davemloft.net>
References: <20090221222318.6451.16633.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57838
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754474AbZBUXmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 18:42:37 -0500
In-Reply-To: <20090221222318.6451.16633.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 21 Feb 2009 14:23:19 -0800

> In order to work around a silicon errata on 82598 we need to disable L0's
> in the PCIe switch port to which the 82598 is connected, to prevent the
> duplicate completions caused by L0s.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

You can't implement this at this level guys.

PCI-E port hacks inside of individual child drivers will only
cause new bugs where these settings interfere with whatever
the PCI-E port driver wants to do.

Solve this either generically as a quirk in the PCI layer or
as some kind of PCI-E port driver attribute that can be
acted upon.
