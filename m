From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] try parent numa_node at first before using default
Date: Thu, 12 Jul 2007 12:06:00 -0700
Message-ID: <86802c440707121206i3186fe9chba55fe2e5e5e4c5@mail.gmail.com>
References: <200707101641.17672.yinghai.lu@sun.com>
	 <469610D4.70009@s5r6.in-berlin.de>
	 <20070712172310.4d662e1f@gondolin.boeblingen.de.ibm.com>
	 <200707121059.54320.yinghai.lu@sun.com>
	 <20070712183141.GB22471@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Cornelia Huck" <cornelia.huck@de.ibm.com>,
	"Stefan Richter" <stefanr@s5r6.in-berlin.de>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Andi Kleen" <ak@suse.de>, rientjes@google.com,
	"Christoph Lameter" <clameter@sgi.com>,
	"Christoph Hellwig" <hch@infradead.org>,
	"David Miller" <davem@davemloft.net>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:64076 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151AbXGLTGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 15:06:01 -0400
Received: by nz-out-0506.google.com with SMTP id s18so222344nze
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 12:06:01 -0700 (PDT)
In-Reply-To: <20070712183141.GB22471@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/12/07, Greg KH <greg@kroah.com> wrote:
> On Thu, Jul 12, 2007 at 10:59:53AM -0700, Yinghai Lu wrote:
> Please split this into two separate patches, as they are doing two
> different things.  One for the driver core, and one for pci devices.

they need to applied together, otherwise all pci_dev numa_node will be
change to device_add to -1 after pci_device_add.

>
> Also, what kind of performance issues have you seen with this patch in
> place?  As your previous patches were incorrect, I am guessing that you
> are not able to test this?
forcedeth on second node. without this patch in addition to
get_mpbus_to_node patch, the numa_node is always 0.


LBsuse91AMD64:/sys/devices/pci0000:80/0000:80:08.0 # cat numa_node
1
LBsuse91AMD64:/sys/devices/pci0000:80/0000:80:08.0 # cat net/eth2/numa_node
1

and after initialization

LBsuse91AMD64:~ # tail -10 /var/log/messages
Jul 13 03:05:16 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011d33d010, 11d33d010, 670
Jul 13 03:05:26 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011d322010, 11d322010, 670
Jul 13 03:05:29 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011d33a810, 11d33a810, 670
Jul 13 03:05:31 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011d33e810, 11d33e810, 670
Jul 13 03:05:31 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011d358810, 11d358810, 670
Jul 13 03:05:31 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011cfe1010, 11cfe1010, 670
Jul 13 03:05:31 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011cfe1810, 11cfe1810, 670
Jul 13 03:05:31 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011c7f9010, 11c7f9010, 670
Jul 13 03:05:31 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011c7f9810, 11c7f9810, 670
Jul 13 03:05:34 LBsuse91AMD64 kernel: forcedeth 0000:00:08.0: YHLU
gart_map_single - !need_iommu: ffff81011c2a7010, 11c2a7010, 670

gart_map_single is used all the time via netdev_alloc_skb for forcedth.

YH
