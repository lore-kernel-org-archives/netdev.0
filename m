From: wangyufen <wangyufen@huawei.com>
Subject: [Bug Report] use bonding lacp mode aggregation NIC has performance
 problems while  intel_immu switch opening
Date: Fri, 28 Jun 2013 16:59:14 +0800
Message-ID: <51CD5062.5050501@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <joro@8bytes.org>, <Varun.Sethi@freescale.com>, <aik@ozlabs.ru>,
	<alex.williamson@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <zhangdianfang@huawei.com>,
	Li Zefan <lizefan@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

           Summary: use bonding lacp mode aggregation NIC has performance problems while  intel_immu switch opening
           Product: Networking
           Version: 
    Kernel Version: 3.10.0-rc5
          Platform: X86
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: bonding&ixgbe
        AssignedTo: 
        ReportedBy: wangyufen@huawei.com,wangweidong1@huawei.com
        Regression: No


Hi I'am using bonding lacp mode aggregation intel 82599 NIC, there are  performance problems while intel_immu switch is open.
I'am using iperf to test the network speeds.
When intel_immu switch is closed, 4 port after polymerization, the network port speeds up to 37.6 Gbits / sec,
when intel_immu switch is turned on, 4port After polymerization, the network port speed only to 28.7 Gbits / sec.


intel_iommu=off
dma_ops = &swiotlb_dma_ops,so map_page = swiotlb_map_page and unmap_page = swiotlb_unmap_page
intel_iommu=on
dma_ops = &intel_dma_ops,so map_page=intel_map_page and unmap_page=intel_unmap_page

I think the intel_dma_ops will cost more performance, and the dma_map_page and
dma_map_single_attrs will call map_page(),but the paramters is not same. Therefor, I do a test
about the time of funcs call map_page or unmap_page.

----------------------------------------------------------------------------
func\count				350(*10000)		
dma_map_single_attrs,iommu-off		640000(ns)~1000000(ns)		
dma_map_single_attrs,iommu-on		4900000(ns)~5700000(ns)
dma_unmap_single_attrs,iommu-off	330000(ns)~620000(ns)
dma_unmap_single_attrs,iommu-on		3000000(ns)~47000000(ns)

func\count				2900(*10000)
dma_map_page,iommu-off			350000(ns)~610000(ns)
dma_map_page,iommu-on			2160000(ns)~3000000(ns)
dma_unmap_page,iommu-off		345000(ns)~670000(ns)
dma_unmap_page,iommu-on			3000000(ns)~4300000(ns)
----------------------------------------------------------------------------
the time that map and unmap function cost show huge gap when iommu is on and off.
