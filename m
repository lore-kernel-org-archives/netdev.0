From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [patch 08/20] ibmveth: Dont overallocate buffers
Date: Mon, 23 Aug 2010 15:49:17 -0500
Message-ID: <20100823204916.GB15499@linux.vnet.ibm.com>
References: <20100823000930.546065833@samba.org>
 <20100823001239.041525926@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:55389 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753021Ab0HWUtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 16:49:19 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7NKYTFd028712
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 16:34:29 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7NKnIZd475216
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 16:49:18 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7NKnHrD027927
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 14:49:18 -0600
Content-Disposition: inline
In-Reply-To: <20100823001239.041525926@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Anton Blanchard (anton@samba.org) wrote:
> We were allocating a page, even though we always want 4k. Use kmalloc
> instead of get_zeroed_page.

I get a failure during device open when we have a 4k allocation rather
than a 64k page allocation.  This is running on a Power6 LPAR without
AMS.

(drivers/net/ibmveth.c:621 ua:3000000c) ERROR: h_register_logical_lan failed with -4
(drivers/net/ibmveth.c:626 ua:3000000c) ERROR: buffer TCE:0x300 filter TCE:0x2300 rxq desc:0x8000601000004000 MAC:0x763cbdd9d30c

