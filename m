From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] nfp: get_phys_port_name for
 representors and SR-IOV reorder
Date: Tue, 27 Jun 2017 15:51:17 -0400 (EDT)
Message-ID: <20170627.155117.1691647324384235393.davem@davemloft.net>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753444AbdF0TvT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 15:51:19 -0400
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 27 Jun 2017 00:50:14 -0700

> This series starts by making the error message if FW cannot be located
> easier to understand.  Then I move some functions from PCI probe files
> into library code (nfpcore) where they belong, and remove one function
> which is never used.
> 
> Next few patches equip representors with nfp_port structure and make
> their NDOs fully shared (not defined in apps), thanks to which we can 
> easily determine which netdevs are NFP's by comparing the NDO pointers.
> 
> 10th patch makes use of the shared NDOs and nfp_ports to deliver
> netdev-type independent .ndo_get_phys_port_name() implementation.
> 
> Patches 11 and 12 reorder the nfp_app SR-IOV callbacks with enabling
> SR-IOV VFs.  Unfortunately due to how PCI subsystem works we can't
> guarantee being able to disable SR-IOV at exit or that it will be
> disabled when we first probe...  We must therefore make sure FW is
> able to deal with being loaded while SR-IOV is already on.
> 
> Patch 13 fixes potential deadlock when enabling SR-IOV happens at
> the same time as port state refresh.  Note that this can't happen
> at this point, since Flower doesn't refresh ports... but lockdep 
> doesn't know about such details and we will have to deal with this
> sooner or later anyway.
> 
> Last but not least a new Kconfig is added to make sure those who 
> don't care about flower offloads have a way of not including the 
> code in their kernels.  Thanks to nfp_app separation this costs us
> a single ifdef and excluding flower files from the build.

Series applied, thanks.
