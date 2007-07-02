From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 11:32:41 -0400
Message-ID: <46891A99.7090003@garzik.org>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070612234431.5102.33880.stgit@localhost.localdomain> <4688F512.3030801@garzik.org> <4689062A.8080809@linux.intel.com> <46890AED.7070906@garzik.org> <46890B39.4050909@linux.intel.com> <46890E7C.9070204@garzik.org> <46891939.2030805@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52607 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384AbXGBPcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 11:32:45 -0400
In-Reply-To: <46891939.2030805@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Maybe this is not most important for ixgbe, where we only have 8 or so 
> flags, but the new e1000 driver that I posted this weekend currently has 
> 63 (you wanted flags ;)) of them. Do you want me to use 63 integers or 
> just 2 ?


Don't be silly.  We are talking about single-bit feature flags 
implemented using machine ints (a la tg3 with 32 flags per int), versus 
bitfields.

Bitfields are to be avoided for many reasons:
* more difficult, in general, for a compiler to generate optimal code
* in particular, known to generate worse code on various architectures
* often causes endian problems
* often enhances programmer confusion, when trying to review structs and 
determine optimal layout and alignment
* programmers have proven they will screw up bitfields in e.g. cases 
with 1-bit and signedness.

I can probably think up more reasons to avoid bitfields if given another 
5 minutes :)

	Jeff


