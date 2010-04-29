From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: enable/disable ASPM L0s and L1 and ERT
 according to hardware errata
Date: Thu, 29 Apr 2010 12:04:16 -0700 (PDT)
Message-ID: <20100429.120416.184828647.davem@davemloft.net>
References: <20100427133232.25490.92973.stgit@localhost.localdomain>
	<20100429074606.GA12437@kryten>
	<8DD2590731AB5D4C9DBF71A877482A9062274501@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, mjg@redhat.com
To: bruce.w.allan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59743
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752972Ab0D3Qsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 12:48:35 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A9062274501@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Date: Thu, 29 Apr 2010 10:19:56 -0700

> Your patch is probably the correct thing to do but I'm not all that
> familiar with the ppc64 architecture.  Would you please provide the
> output of 'lspci -t' and 'lspci -vvv -xxx'.

You're not guarenteed for there to be a pci_dev backing the top-level
host controller, at the very least.  Some platforms don't even implement
the PCI config space for the host controller, whilst on others access
to them is protected by the hypervisor.

So you can't go poking around the PCI host controller registers
unconditionally.

The same OOPS probably would happen on Sparc64 in some configurations
too.  Although all of my PCI-E slots do have PCI-E express switch port
nodes, so maybe it wouldn't trigger here.

