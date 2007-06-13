From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [ANNOUNCE] new driver ixgbe for Intel(R) 10GbE PCI Express adapters.
Date: Wed, 13 Jun 2007 16:18:23 -0700
Message-ID: <46707B3F.5020205@intel.com>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070613230513.GB22521@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayyappan.Veeraiyan@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, arjan@linux.intel.com, akpm@linux-foundation.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53186 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756530AbXFMXS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 19:18:26 -0400
In-Reply-To: <20070613230513.GB22521@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Ayyappan.Veeraiyan@intel.com <Ayyappan.Veeraiyan@intel.com> :
> [...]
>> Please review and provide comments.
> 
> o ixgbe_call_func and the ton of wrappers which go along with it
>   should go.

hmmm good point, this is a bit too verbose perhaps ;)

> o boolean_t duplicates the existing 'bool'

yes, that's definately on the TODO list.... did I mention that sparse really 
doesn't like bool yet? :)

> o The options below {should be/are} handled through ethtool:
>   - TxDescriptors
>   - RxDescriptors
>   - XsumRX

I have been putting this on the todo list as well, but we kept it in for 
convenience reasons... not to mention that we've been keeping these options 
around in the other drivers, is there really a pressing need to remove them? 
I'll put it on the todo list for sure tho.

> o No __iomem annotations ?

Ack! that slipped through the cracks... DOH

> o pci_alloc_consistent() returns a zeroed area: no need for memset.

that is good to know, I didn't know that

> o ixgbe_clean_tx_irq() is issued from the NAPI poll handler (as the
>   name suggests...). Its locking will probably cause a deadlock if
>   it is interrupted and a call to netpoll_send_skb follows.

OK, we'll look into that. I'm not sure this is an issue tho.


Thanks for the feedback!

Auke

Auke
