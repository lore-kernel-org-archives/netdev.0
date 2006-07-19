From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Don't call request_region() for 3C90x chips
Date: Wed, 19 Jul 2006 13:57:37 -0400
Message-ID: <44BE7291.2080306@pobox.com>
References: <200607102225.49253.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51333 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932331AbWGSR5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 13:57:40 -0400
To: Sergei Shtylylov <sshtylyov@ru.mvista.com>
In-Reply-To: <200607102225.49253.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylylov wrote:
> It's generally not a good idea to call request_region() on an address returned 
> by pci_iomap(), even less so on a MMIO address. And there was absolutely no 
> point in claiming the region already claimed by the PCI core, especially with 
> the same PCI generic owner's name. As this is the only case of the 
> must_free_region flag being set, this flag may go away as well...
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

I agree you have identified a bug, but this is not a solution.

The current driver bug is that it calls request_region() potentially on 
an MMIO address, but the solution is _not_ to completely avoid reserving 
the resource.

The region registered with the PCI core, but _not_ claimed by anyone. 
Someone still needs to either call pci_{request,release}_regions() or 
request_[mem_]region() to indicate that the resource is reserved.

This bug you have found was probably a missed detail during the 
conversion to the iomap API.

	Jeff


