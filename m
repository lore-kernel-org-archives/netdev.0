From: "Kok, Auke" <sofar@foo-projects.org>
Subject: Re: New NAPI API: Need for netif_napi_remove() ?!
Date: Mon, 10 Sep 2007 17:27:33 -0700
Message-ID: <46E5E0F5.6080607@foo-projects.org>
References: <46E5DECE.30206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:11718 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755760AbXIKA1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 20:27:42 -0400
In-Reply-To: <46E5DECE.30206@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> David,
> 
>  From an old thread:
> 
>  > 5) Since, in the NETPOLL case, netif_napi_init() adds the NAPI struct
>  >   to the per-device list I renamed it to netif_napi_add().  Currently
>  >   no teardown is really necessary, anything that would need to be done
>  >   would be driver internal, so I didn't create the corollary
>  >   netif_napi_remove() for the time being.  Let's not add it unless it
>  >   really becomes necessary.
> 
> while coding the NAPI API changes into the ixgbe driver, I notice that I'm in 
> need for an implementation for netif_napi_remove(). The ixgbe driver itself 
> already modifies it's polling routing on open() and close() based on whether it 
> was able to acquire MSI-X vectors or not, and can thus logically change as the 
> system suspends/resumes and new hardware is inserted that change the balance in 
> the MSI-X vectors in the system. Or, even more bluntly, all MSI support is 
> disabled and we want the driver to come up in legacy mode and use a completely 
> different poll routine alltogether. We can't do this at probe time.
> 
> In any case I think we have a legitimate case for netif_napi_remove() to be 
> implemented.


hm, I spoke too soon, I think I can get by for now by just modifying 
adapter->napi.poll when needed, and this would be clean enough for now. This 
might change as I enable multiqueue in this driver later though.

Auke
