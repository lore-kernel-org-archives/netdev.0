From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Any ideas about a crash on reboot with igb and intel_iommu?
Date: Fri, 02 Apr 2010 11:13:03 -0700
Message-ID: <adahbnt7mfk.fsf@roland-alpha.cisco.com>
References: <adabpe3f3c4.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: iommu@lists.linux-foundation.org,
	David Woodhouse <dwmw2@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:63170 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab0DBSNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 14:13:09 -0400
In-Reply-To: <adabpe3f3c4.fsf@roland-alpha.cisco.com> (Roland Dreier's message
	of "Thu, 01 Apr 2010 11:13:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So actually I found the following change that went into 2.6.31:

    commit 91615f765a2935b6cbae424b9eee1585ed681ae6
    Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
    Date:   Tue Jun 30 12:45:15 2009 +0000

        igb: fix unmap length bug
        
        driver was mixing NET_IP_ALIGN count bytes in map/unmap calls
        unevenly. Only map the bytes that the hardware might dma into

igb in 2.6.30.y is doing pci_map_single(<some length>) and doing
pci_unmap_single(<some other length>).

However I haven't been able to provoke the crash yet, even by bouncing
an igb interface (with VT-d turned on and with CONFIG_DMAR_DEFAULT_ON enabled).
Does this make sense as the sort of thing that might corrupt the iova
rbtree and lead to a crash in the __free_iova / rb_erase code?

Thanks,
  Roland
-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
