From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: NETIF_F_HIGHDMA?
Date: Thu, 13 Feb 2014 02:00:19 +0300
Message-ID: <52FBFD03.6000703@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:47139 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaBLWAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:00:18 -0500
Received: by mail-lb0-f178.google.com with SMTP id u14so7723772lbd.9
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 14:00:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

    I fail to understand why this flag is needed at all. netdev-features.txt says:

  * Transmit DMA from high memory

On platforms where this is relevant, NETIF_F_HIGHDMA signals that
ndo_start_xmit can handle skbs with frags in high memory.

    TTBOMK, highmem is an area of the kernel *virtual* memory that maps 
physical memory that can't be directly mapped unto the linear kernel space, 
i.e. in case when there's more memory in the system than the kernel memory can 
directly map. But what this has to do with DMA which deals with the physical 
memory? High memory doesn't have to be beyond 4 GiB limit -- it can exist even 
on 32-bit system (consider 4 GiB memory and 2/2 or 3/1 GiB user/kernel VM 
split), contrary to the belief of the many Ethernet PCI drivers which only set 
NETIF_F_HIGHDMA when the PCI dual address cycle is supported (i.e. the address 
on PCI can be 64-bit)...

    So, in my opinion, each and every driver should set this flag (except 
maybe those arch-specific drivers where CONFIG_HIGHMEM is not supported but 
even it this case the flag wouldn't hurt), and hence it's not needed at all. 
What am I missing in my picture?

WBR, Sergei
