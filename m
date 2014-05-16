From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Add support for device specific address
 syncing
Date: Thu, 15 May 2014 23:05:40 -0400 (EDT)
Message-ID: <20140515.230540.466419985495775051.davem@davemloft.net>
References: <20140514233444.29822.45400.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbaEPDFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 23:05:41 -0400
In-Reply-To: <20140514233444.29822.45400.stgit@ahduyck-cp2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 14 May 2014 16:37:27 -0700

> This change provides a function to be used in order to break the
> ndo_set_rx_mode call into a set of address add and remove calls.  The code
> is based on the implementation of dev_uc_sync/dev_mc_sync.  Since they
> essentially do the same thing but with only one dev I simply named my
> functions __dev_uc_sync/__dev_mc_sync.
> 
> I also implemented an unsync version of the functions as well to allow for
> cleanup on close.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> 
> I still have to do some testing on this patch, but I am looking to see if
> this is the correct approach or if the community would prefer I take a
> different one.

I just wonder about error handling.

The code just seems to stop trying to sync() if one intermediate
sync() fails.

Shouldn't we unwind or signal errors to the caller?

Is the idea that the driver has internal state which will track if
something goes wrong and take care of error recovery itself?  If so,
that kind of indirect error handling doesn't sit too well with me.
