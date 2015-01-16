From: Quentin Lambert <lambert.quentin@gmail.com>
Subject: Re: [net-next PATCH v3 1/1] atm: remove deprecated use of pci api
Date: Fri, 16 Jan 2015 15:10:25 +0100
Message-ID: <54B91BD1.70909@gmail.com>
References: <20150112161042.GA11374@sloth>	<20150113.215944.1703977685948196746.davem@davemloft.net>	<063D6719AE5E284EB5DD2968C1650D6D1CAC79B3@AcuExch.aculab.com> <20150116085721.56aa8075@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	"linux-atm-general@lists.sourceforge.net"
	<linux-atm-general@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35654 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbbAPOKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 09:10:25 -0500
In-Reply-To: <20150116085721.56aa8075@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 16/01/2015 14:57, chas williams - CONTRACTOR wrote:
>
> Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
> ---
>   drivers/atm/eni.c       |  33 +++++++------
>   drivers/atm/fore200e.c  |  22 +++++----
>   drivers/atm/he.c        | 125 +++++++++++++++++++++++++-----------------------
>   drivers/atm/he.h        |   4 +-
>   drivers/atm/idt77252.c  | 107 ++++++++++++++++++++++-------------------
>   drivers/atm/iphase.c    |  54 +++++++++++----------
>   drivers/atm/lanai.c     |  14 ++----
>   drivers/atm/nicstar.c   |  60 +++++++++++------------
>   drivers/atm/solos-pci.c |  26 +++++-----
>   drivers/atm/zatm.c      |  17 ++++---
>   10 files changed, 243 insertions(+), 219 deletions(-)
>
[]
> diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
> index d5d9eaf..75dde90 100644
> --- a/drivers/atm/fore200e.c
> +++ b/drivers/atm/fore200e.c
> @@ -425,7 +425,7 @@ static void fore200e_pca_write(u32 val, volatile u32 __iomem *addr)
>   static u32
>   fore200e_pca_dma_map(struct fore200e* fore200e, void* virt_addr, int size, int direction)
>   {
> -    u32 dma_addr = pci_map_single((struct pci_dev*)fore200e->bus_dev, virt_addr, size, direction);
> +    u32 dma_addr = dma_map_single(&((struct pci_dev *) fore200e->bus_dev)->dev, virt_addr, size, direction);
>   
>       DPRINTK(3, "PCI DVMA mapping: virt_addr = 0x%p, size = %d, direction = %d,  --> dma_addr = 0x%08x\n",
>   	    virt_addr, size, direction, dma_addr);
>
[]

I am going try to make similar changes in some other part of the kernel and
I was wondering if you could explain how you decided it wasn't necessary to
check for "((struct pci_dev *) fore200e->bus_dev" nullity for instance.

Thanks,

Quentin
