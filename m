From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] rds_rdma: don't assume infiniband device is PCI
Date: Tue, 29 May 2012 17:22:46 -0400 (EDT)
Message-ID: <20120529.172246.489250268136410473.davem@davemloft.net>
References: <1338231125-9005-1-git-send-email-cascardo@linux.vnet.ibm.com>
	<4FC3DCD6.5020604@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	dledford@redhat.com, Jes.Sorensen@redhat.com
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755892Ab2E2VXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 17:23:00 -0400
In-Reply-To: <4FC3DCD6.5020604@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Date: Mon, 28 May 2012 15:15:18 -0500

> On 5/28/2012 1:52 PM, Thadeu Lima de Souza Cascardo wrote:
>> RDS code assumes that the struct ib_device dma_device member, which is
>> a
>> pointer, points to a struct device embedded in a struct pci_dev.
>>
>> This is not the case for ehca, for example, which is a OF driver, and
>> makes dma_device point to a struct device embedded in a struct
>> platform_device.
>>
>> This will make the system crash when rds_rdma is loaded in a system
>> with ehca, since it will try to access the bus member of a
>> non-existent
>> struct pci_dev.
>>
>> The only reason rds_rdma uses the struct pci_dev is to get the NUMA
>> node
>> the device is attached to. Using dev_to_node for that is much better,
>> since it won't assume which bus the infiniband is attached to.
>>
>> Signed-off-by: Thadeu Lima de Souza
>> Cascardo<cascardo@linux.vnet.ibm.com>
>> Cc: dledford@redhat.com
>> Cc: Jes.Sorensen@redhat.com
>> Cc: Venkat Venkatsubra<venkat.x.venkatsubra@oracle.com>
>> ---
>>
> Acked-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>

Applied.
