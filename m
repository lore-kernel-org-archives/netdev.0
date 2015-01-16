From: Quentin Lambert <lambert.quentin@gmail.com>
Subject: Re: [net-next PATCH v3 1/1] atm: remove deprecated use of pci api
Date: Fri, 16 Jan 2015 15:54:12 +0100
Message-ID: <54B92614.5090900@gmail.com>
References: <20150112161042.GA11374@sloth>	<20150113.215944.1703977685948196746.davem@davemloft.net>	<063D6719AE5E284EB5DD2968C1650D6D1CAC79B3@AcuExch.aculab.com>	<20150116085721.56aa8075@thirdoffive.cmf.nrl.navy.mil>	<54B91BD1.70909@gmail.com> <20150116095244.40249284@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150116095244.40249284@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 16/01/2015 15:52, chas williams - CONTRACTOR wrote:
> On Fri, 16 Jan 2015 15:10:25 +0100
> Quentin Lambert <lambert.quentin@gmail.com> wrote:
>
>
>>> -    u32 dma_addr = pci_map_single((struct pci_dev*)fore200e->bus_dev, virt_addr, size, direction);
>>> +    u32 dma_addr = dma_map_single(&((struct pci_dev *) fore200e->bus_dev)->dev, virt_addr, size, direction);
>>>    
>>>        DPRINTK(3, "PCI DVMA mapping: virt_addr = 0x%p, size = %d, direction = %d,  --> dma_addr = 0x%08x\n",
>>>    	    virt_addr, size, direction, dma_addr);
>>>
>> []
>>
>> I am going try to make similar changes in some other part of the kernel and
>> I was wondering if you could explain how you decided it wasn't necessary to
>> check for "((struct pci_dev *) fore200e->bus_dev" nullity for instance.
> This gets set up in fore200e_pca_detect() which is pretty early in the
> intialization process.  We don't get as far as using any of the "DVMA"
> stubs unless pci_enable_device() succeeds, meaning pci_dev is good, and
> fore200e->bus_dev is assigned to pci_dev (around line 2724).
>
> fore200e->bus_dev is never cleared back to NULL, but obviously you
> shouldn't be using any of the DMA routines after disabling the pci
> device.  Hopefully the driver shuts down in an orderly fashion such
> that all DMA is over by the time the driver disables the pci device.
Thank you
