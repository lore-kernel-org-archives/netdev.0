From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: Re: [PATCH resend] rds_rdma: don't assume infiniband device is PCI
Date: Mon, 28 May 2012 15:15:18 -0500
Message-ID: <4FC3DCD6.5020604@oracle.com>
References: <1338231125-9005-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	dledford@redhat.com, Jes.Sorensen@redhat.com
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:35902 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567Ab2E1UPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 16:15:31 -0400
In-Reply-To: <1338231125-9005-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/28/2012 1:52 PM, Thadeu Lima de Souza Cascardo wrote:
> RDS code assumes that the struct ib_device dma_device member, which is a
> pointer, points to a struct device embedded in a struct pci_dev.
>
> This is not the case for ehca, for example, which is a OF driver, and
> makes dma_device point to a struct device embedded in a struct
> platform_device.
>
> This will make the system crash when rds_rdma is loaded in a system
> with ehca, since it will try to access the bus member of a non-existent
> struct pci_dev.
>
> The only reason rds_rdma uses the struct pci_dev is to get the NUMA node
> the device is attached to. Using dev_to_node for that is much better,
> since it won't assume which bus the infiniband is attached to.
>
> Signed-off-by: Thadeu Lima de Souza Cascardo<cascardo@linux.vnet.ibm.com>
> Cc: dledford@redhat.com
> Cc: Jes.Sorensen@redhat.com
> Cc: Venkat Venkatsubra<venkat.x.venkatsubra@oracle.com>
> ---
>
Acked-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
