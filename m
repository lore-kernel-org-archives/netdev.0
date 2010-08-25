From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [patch 08/20] ibmveth: Dont overallocate buffers
Date: Wed, 25 Aug 2010 08:44:16 -0500
Message-ID: <4C751E30.6020408@linux.vnet.ibm.com>
References: <20100823000930.546065833@samba.org> <20100823001239.041525926@samba.org> <20100823204916.GB15499@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Anton Blanchard <anton@samba.org>, santil@linux.vnet.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:44697 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233Ab0HYNoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 09:44:16 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7PDQJJP000972
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 09:26:19 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7PDiF5P078532
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 09:44:15 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7PDiDpm008038
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 07:44:13 -0600
In-Reply-To: <20100823204916.GB15499@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2010 03:49 PM, Robert Jennings wrote:
> * Anton Blanchard (anton@samba.org) wrote:
>> We were allocating a page, even though we always want 4k. Use kmalloc
>> instead of get_zeroed_page.
> 
> I get a failure during device open when we have a 4k allocation rather
> than a 64k page allocation.  This is running on a Power6 LPAR without
> AMS.
> 
> (drivers/net/ibmveth.c:621 ua:3000000c) ERROR: h_register_logical_lan failed with -4
> (drivers/net/ibmveth.c:626 ua:3000000c) ERROR: buffer TCE:0x300 filter TCE:0x2300 rxq desc:0x8000601000004000 MAC:0x763cbdd9d30c

According to the architecture, these buffers need to be 4k aligned buffers,
which is probably the cause of this failure.

-Brian

-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center


