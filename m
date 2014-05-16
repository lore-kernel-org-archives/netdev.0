From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Add support for device specific address
 syncing
Date: Fri, 16 May 2014 15:01:15 -0400 (EDT)
Message-ID: <20140516.150115.1106293449904617860.davem@davemloft.net>
References: <20140514233444.29822.45400.stgit@ahduyck-cp2.jf.intel.com>
	<20140515.230540.466419985495775051.davem@davemloft.net>
	<53765D5D.9040207@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378AbaEPTBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 15:01:22 -0400
In-Reply-To: <53765D5D.9040207@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 16 May 2014 11:47:57 -0700

> I suppose I should break up the loop below though.  It might be better
> to do all of the usnync operations first before the sync in the case of
> a interface with a limited number of unicast of multicast filters.
 ...
> My primary use case for this is to simplify mailbox operations between
> two entities such as a PF and VF.  With this the VF only needs to send a
> request for new addresses instead of having to send the entire list via
> the mailbox.  The issue most likely to cause an error is a mailbox error
> which I admit does have some of its own error recovery in the case of a
> message timeout.

I definitely agree that we should be doing the unsync()'s first.

>From a quality of implementation standpoint, the promisc mode needs
should be determined in both sync() and unsync().
