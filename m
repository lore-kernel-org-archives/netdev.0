From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH] net: Add support for device specific address syncing
Date: Fri, 16 May 2014 12:55:42 -0700
Message-ID: <53766D3E.4080904@intel.com>
References: <20140514233444.29822.45400.stgit@ahduyck-cp2.jf.intel.com>	<20140515.230540.466419985495775051.davem@davemloft.net>	<53765D5D.9040207@intel.com> <20140516.150115.1106293449904617860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30253 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756606AbaEPTzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 15:55:43 -0400
In-Reply-To: <20140516.150115.1106293449904617860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2014 12:01 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Fri, 16 May 2014 11:47:57 -0700
> 
>> I suppose I should break up the loop below though.  It might be better
>> to do all of the usnync operations first before the sync in the case of
>> a interface with a limited number of unicast of multicast filters.
>  ...
>> My primary use case for this is to simplify mailbox operations between
>> two entities such as a PF and VF.  With this the VF only needs to send a
>> request for new addresses instead of having to send the entire list via
>> the mailbox.  The issue most likely to cause an error is a mailbox error
>> which I admit does have some of its own error recovery in the case of a
>> message timeout.
> 
> I definitely agree that we should be doing the unsync()'s first.
> 
> From a quality of implementation standpoint, the promisc mode needs
> should be determined in both sync() and unsync().
> 

I can understand going into promisc on a sync failure, but why would you
do it on an unsync failure, or are you saying that we would be clearing
the flag in unsync?

In general I intended for this to be called in set_rx_mode so if
__dev_uc_sync returns an error indicating insufficient resources we have
to force IFF_PROMISC on because adding a new address failed.  We could
also do the same thing for __dev_mc_sync and IFF_ALLMULTI.

Thanks,

Alex
