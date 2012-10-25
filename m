From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [E1000-devel] dma_map_page and dma_map_single
Date: Thu, 25 Oct 2012 09:21:54 -0700
Message-ID: <50896722.1050307@intel.com>
References: <CAGZFCEGLhEp7+sD98-HjQFwbkVo70M2OWh29Y+yG5xwbm82obw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11842 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932845Ab2JYQXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 12:23:33 -0400
In-Reply-To: <CAGZFCEGLhEp7+sD98-HjQFwbkVo70M2OWh29Y+yG5xwbm82obw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use dma_map_single here because we have a virtual pointer and not a
page.  If you look in the kernel at the file
include/asm-generic/dma-mapping-common.h you will see that
dma_map_single_attrs which is what ends up being called when we call
dma_map_single will convert the pointer to a page and then call
map_page.  This way we don't have to place the overhead for the code
directly in our driver.

Thanks,

Alex

On 10/25/2012 01:58 AM, ratheesh kannoth wrote:
> Hi ,
>
> I was looking at tx_map ( igb-3.3.6  ) in igb driver. I could see that
> dma_map_single is used for first buffer and dma_map_page is used for
> the fragments.
>
> What is the real difference  between these api ?  we can replace
> dma_map_single with dma_map_page. then  why  we used dma_map_single
> here ?.
>
> Thanks,
> Ratheesh
>
