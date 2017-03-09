From: Romain Perier <romain.perier@collabora.com>
Subject: Re: [PATCH v5 04/19] net: e100: Replace PCI pool old API
Date: Thu, 9 Mar 2017 10:58:30 +0100
Message-ID: <eab51598-decb-ba26-0ac4-733d9a7f4317@collabora.com>
References: <20170308161957.28941-1-romain.perier@collabora.com>
 <20170308161957.28941-5-romain.perier@collabora.com>
 <1489012825.3477.51.camel@intel.com> <20170309070129.GA13741@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Peter Senna Tschudin <peter.senna@collabora.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:35891 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754510AbdCIJ6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 04:58:44 -0500
In-Reply-To: <20170309070129.GA13741@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,


Le 09/03/2017 à 08:01, Peter Senna Tschudin a écrit :
> On Wed, Mar 08, 2017 at 02:40:25PM -0800, Jeff Kirsher wrote:
>> On Wed, 2017-03-08 at 17:19 +0100, Romain Perier wrote:
>>> The PCI pool API is deprecated. This commit replaces the PCI pool old
>>> API by the appropriate function with the DMA pool API.
>>>
>>> Signed-off-by: Romain Perier <romain.perier@collabora.com>
>>> Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
>>> Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
>>> ---
>>>  drivers/net/ethernet/intel/e100.c | 12 ++++++------
>>>  1 file changed, 6 insertions(+), 6 deletions(-)
>> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>
>> My only concern is:
>> - what hardware did this get tested with?  Since this affects all e100
>> parts, it would be hard to believe that all the affected hardware was
>> used in testing.
> This was tested by compilation only(See
> https://lkml.org/lkml/2017/2/8/661). However this series removes macro
> definitions of the old pci_pool interface and replace call sites by what
> the macra was calling.
>
> Here are the macros that this series removes from include/pci.h:
>
> #define pci_pool dma_pool
> #define pci_pool_create(name, pdev, size, align, allocation) \
> 	dma_pool_create(name, &pdev->dev, size, align, allocation)
> #define pci_pool_destroy(pool) dma_pool_destroy(pool)
> #define pci_pool_alloc(pool, flags, handle) dma_pool_alloc(pool, flags, handle)
> #define pci_pool_zalloc(pool, flags, handle) \
> 	dma_pool_zalloc(pool, flags, handle)
> #define pci_pool_free(pool, vaddr, addr) dma_pool_free(pool, vaddr, add
>
> So this should not affect run time.
We cannot test a patch like this one on all affected platforms/drivers
(at runtime). Simply because we have not the hw. As Peter said, we
tested this by compilation only for now via make allyesconfig. That's up
to the maintainer of the subsystem to test and ack this, imho.
I agree with Peter, this should not affect runtime (as semantically it's
compatible and have been validated statically and semantically by your
compiler)

Regards,
Romain
