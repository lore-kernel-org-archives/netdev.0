From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/8] Fix TSO and checksum issues with
 non-accelerated vlan traffic.
Date: Mon, 25 Aug 2014 17:28:04 -0700 (PDT)
Message-ID: <20140825.172804.1112825546843491474.davem@davemloft.net>
References: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, rmody@brocade.com,
	cascardo@linux.vnet.ibm.com, thomas.petazzoni@free-electrons.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	ron.mercer@qlogic.com, linux-driver@qlogic.com, cmetcalf@tilera.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933658AbaHZA2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:28:06 -0400
In-Reply-To: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Mon, 25 Aug 2014 10:34:47 -0400

> I've recently ran across something rather interesting when testing vlans
> from inside VMs.  In some scenarios I was getting awfull thruput.
> Some debugging uncovered a very scary packet corruption.  I was
> seeing packets that had original TSO length as IP total length
> and their ip checksum was 0.  This was with e1000e driver.
> 
> A bit more debugging uncovered an assumption made by that driver
> that skb->protocol will contain l3 protocol information.  This
> was not the case in my setup since I manually turned off vlan
> tx acceleration for the device.  This caused the driver to not
> initialize the tso information correctly and resulted in
> corrupt TSO frames on the wire.
> 
> I decided to do some auditing of the usage of skb->protocols
> in the drivers.  Out of all the drivers, the included 8 appear
> to be effected.  They all allow user to control vlan acceleration
> settings, all support TSO on vlan devices, and all use
> skb->protocol to decide how to encode TSO information.  Some
> also have similar problems when initializing hw checksum information.
> On such device, it is simple enough to reproduce the issue.
> Simply turn off TX VLAN acceleration on the device, create a vlan,
> and run you favorite network performance tool.
> 
> There is 1 driver I ran across that I belive will trigger a BUG
> in the system when used with vlans.  That driver is tile/tilepro.c
> I have not changed it in this patch set and would hope that
> the maintainer has time to look at it.
> 
> V2: Fix i40ev using the wrong function name.  Full build.

Applied, thanks.
