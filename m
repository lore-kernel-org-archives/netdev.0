From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: New NAPI API: Need for netif_napi_remove() ?!
Date: Mon, 10 Sep 2007 17:18:22 -0700
Message-ID: <46E5DECE.30206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35687 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824AbXIKASo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 20:18:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David,

 From an old thread:

 > 5) Since, in the NETPOLL case, netif_napi_init() adds the NAPI struct
 >   to the per-device list I renamed it to netif_napi_add().  Currently
 >   no teardown is really necessary, anything that would need to be done
 >   would be driver internal, so I didn't create the corollary
 >   netif_napi_remove() for the time being.  Let's not add it unless it
 >   really becomes necessary.

while coding the NAPI API changes into the ixgbe driver, I notice that I'm in 
need for an implementation for netif_napi_remove(). The ixgbe driver itself 
already modifies it's polling routing on open() and close() based on whether it 
was able to acquire MSI-X vectors or not, and can thus logically change as the 
system suspends/resumes and new hardware is inserted that change the balance in 
the MSI-X vectors in the system. Or, even more bluntly, all MSI support is 
disabled and we want the driver to come up in legacy mode and use a completely 
different poll routine alltogether. We can't do this at probe time.

In any case I think we have a legitimate case for netif_napi_remove() to be 
implemented.

Auke
