From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 3 Aug 2006 10:24:12 -0400
Message-ID: <20060803142412.GA14997@kvack.org>
References: <44D1FEB7.2050703@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:34488 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S932508AbWHCOY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 10:24:27 -0400
To: Arnd Hannemann <arnd@arndnet.de>
Content-Disposition: inline
In-Reply-To: <44D1FEB7.2050703@arndnet.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 03:48:39PM +0200, Arnd Hannemann wrote:
> However the box is a VIA Epia MII12000 with 1 GB of Ram and 1 GB of swap
> enabled, so there should be plenty of memory available. HIGHMEM support
> is off. The e1000 nic seems to be an 82540EM, which to my knowledge
> should support jumboframes.

> However I can't always reproduce this on a freshly booted system, so
> someone else may be the culprit and leaking pages?
> 
> Any ideas how to debug this?

This is memory fragmentation, and all you can do is work around it until 
the e1000 driver is changed to split jumbo frames up on rx.  Here are a 
few ideas that should improve things for you:

	- switch to a 2GB/2GB split to recover the memory lost to highmem
	  (see Processor Type and Features / Memory split)
	- increase /proc/sys/vm/min_free_kbytes -- more free memory will 
	  improve the odds that enough unfragmented memory is available for 
	  incoming network packets

I hope this helps.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
