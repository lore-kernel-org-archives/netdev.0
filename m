From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Thu, 14 Aug 2008 16:45:57 -0400
Message-ID: <48A49985.10704@myri.com>
References: <adazlnlzc60.fsf@cisco.com> <20080809.224637.69833549.davem@davemloft.net> <48A08145.6060703@hp.com> <20080811.141254.165409473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, rdreier@cisco.com, jgarzik@pobox.com,
	swise@opengridcomputing.com, divy@chelsio.com, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, dm@chelsio.com, lee@jasper.es
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2009 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753618AbYHNUrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 16:47:45 -0400
In-Reply-To: <20080811.141254.165409473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
 > From: Rick Jones <rick.jones2@hp.com>
 > Date: Mon, 11 Aug 2008 11:13:25 -0700
 >
 >> David Miller wrote:
 >>> And I even wonder, these days, if you probably get %90 or more of the
 >>> gain these "optimized" iSCSI connections obtain from things like LRO.
 >>> And since LRO can be done entirely in software (although stateless
 >>> HW assistence helps), it is even a NIC agnostic performance 
improvement.
 >> Probably depends on whether or not the iSCSI offload solutions are doing
 >> zero-copy receive into the filecache?
 >
 > That's a data placement issue, which also can be solved with
 > stateless offloading.

Speaking of stateless data placement.  Assume you have a page or set
of pages allocated by a network driver which contain exactly the data
a block driver is interested in to fulfill a read request (eg, the NIC
understands the protocol just well enough to split headers).  Is it
possible in the block driver to simply replace the pages that are
attached to the buf with pages allocated by the network driver?

It was my impression that the pages associated with a buf are in
fairly magical states and that you cannot replace them.  Rather,
you actually need to register them with the NIC, so the NIC can
receive into them rather than into an anonymously allocated page.
At this point, the NIC needs to be smart enough to match the block
read requests with the correct buffer, and you need some kind of
side channel between the network driver and the block driver to
pass the DMA address of the buf's pages and associated read request
tag.

Is this true?

Drew
