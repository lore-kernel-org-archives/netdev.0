From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring
 access in user space
Date: Tue, 13 Jan 2015 12:27:33 -0500 (EST)
Message-ID: <20150113.122733.1459000731112321026.davem@davemloft.net>
References: <54B51BEC.2040809@redhat.com>
	<54B538C1.6000500@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAC6BA5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, dborkman@redhat.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	danny.zhou@intel.com, nhorman@tuxdriver.com,
	john.ronciak@intel.com, brouer@redhat.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbbAMR1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:27:36 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC6BA5@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 13 Jan 2015 17:15:30 +0000

> How about something like:
> 
> struct tpacket_dma_mem_region {
>     __u64 addr;        /* userspace virtual address */
>     __u64 phys_addr;    /* physical address */
>     __u64 iova;        /* IO virtual address used for DMA */
>     __u64 size;    /* size of region */
>     int direction;        /* dma data direction */
> } aligned(8);
> 
> So that it is independant of 32/64 bits.
> It is a shame that gcc has no way of defining a 64bit 'void *' on 32bit systems.
> You can use a union, but you still need to zero extend the value on LE (worse on BE).

We have an __aligned_u64, please use that.
