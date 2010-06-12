From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] enic: fix pci_alloc_consistent argument
Date: Sat, 12 Jun 2010 15:24:46 -0700 (PDT)
Message-ID: <20100612.152446.173856802.davem@davemloft.net>
References: <20100608100020.7d79e932.randy.dunlap@oracle.com>
	<C8340A5F.38161%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, netdev@vger.kernel.org,
	vkolluri@cisco.com, roprabhu@cisco.co
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752761Ab0FLWYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jun 2010 18:24:36 -0400
In-Reply-To: <C8340A5F.38161%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Tue, 08 Jun 2010 14:55:27 -0700

> On 6/8/10 10:00 AM, "Randy Dunlap" <randy.dunlap@oracle.com> wrote:
> 
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>> 
>> Fix build warning on i386 (32-bit) with 32-bit dma_addr_t:
>> 
>> drivers/net/enic/vnic_dev.c: In function 'vnic_dev_init_prov':
>> drivers/net/enic/vnic_dev.c:716: warning: passing argument 3 of
>> 'pci_alloc_consistent' from incompatible pointer type
>> include/asm-generic/pci-dma-compat.h:16: note: expected 'dma_addr_t *' but
>> argument is of type 'u64 *'
>> 
>> Now builds without warnings on i386 and on x86_64.
>> 
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>> Cc: Scott Feldman <scofeldm@cisco.com>
>> Cc: Vasanthy Kolluri <vkolluri@cisco.com>
>> Cc: Roopa Prabhu <roprabhu@cisco.com>
>> ---
>>  drivers/net/enic/vnic_dev.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Acked-by: Scott Feldman <scofeldm@cisco.com>

I'm applying this to net-2.6 since it's also a bug fix, as
passing a u64 pointer in here will make pci_alloc_consistent()
write garbage since it expects a dma_addr_t there which as
on i386 could be 32-bit.
