From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH 2/3] e1000e: Useset_memory_ro()/set_memory_rw() to
	protect flash memory
Date: Wed, 24 Sep 2008 11:13:04 -0700
Message-ID: <B27EBC40D200ED48A3F4CC2EBEABAE0B15607F81@orsmsx501.amr.corp.intel.com>
References: <20080923224535.6869.76210.stgit@jtkirshe-mobile.jf.intel.com>
 <20080924175358.GA2591@phobos.i.cabal.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Kyle McMartin <kyle@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22931 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbYIXSNL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 14:13:11 -0400
In-Reply-To: <20080924175358.GA2591@phobos.i.cabal.ca>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a single page.

We have not been able to reproduce it in-house as yet.

-----Original Message-----
From: Kyle McMartin [mailto:kyle@redhat.com]
Sent: Wednesday, September 24, 2008 10:54 AM
To: Kirsher, Jeffrey T
Cc: jeff@garzik.org; mingo@elte.hu; davem@davemloft.net; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Brandeburg, Jesse; Ronciak, John; Allan, Bruce W
Subject: Re: [PATCH 2/3] e1000e: Useset_memory_ro()/set_memory_rw() to protect flash memory

On Tue, Sep 23, 2008 at 03:45:54PM -0700, Jeff Kirsher wrote:
> +#ifdef _ASM_X86_CACHEFLUSH_H
> +     set_memory_rw((unsigned long)hw->flash_address,
> +                   hw->flash_len >> PAGE_SHIFT);
> +#endif
>       writew(val, hw->flash_address + reg);
> +#ifdef _ASM_X86_CACHEFLUSH_H
> +     set_memory_ro((unsigned long)hw->flash_address,
> +                   hw->flash_len >> PAGE_SHIFT);
> +#endif
>  }

Hi Jeff,

You're making the entire read-only mapping read-write for the single
writel call... why not just limit it to the page that the writel is
targetting?

regards, Kyle
[sorry, I've only been following this at a glance, but it's somewhat
 important for rawhide... does someone have a way to reproduce this at
 whim? Has someone tried catching it using an IOMMU on one of the newer
 Intel boxes, if it is a DMA going awry?]
