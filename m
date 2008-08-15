From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Fri, 15 Aug 2008 08:19:30 -0400
Message-ID: <48A57452.40905@myri.com>
References: <48A08145.6060703@hp.com>	<20080811.141254.165409473.davem@davemloft.net>	<48A49985.10704@myri.com> <20080814.152300.127682912.davem@davemloft.net>
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
Received: from mailbox2.myri.com ([64.172.73.26]:1951 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752877AbYHOM1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 08:27:42 -0400
In-Reply-To: <20080814.152300.127682912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
 > From: Andrew Gallatin <gallatin@myri.com>
 > Date: Thu, 14 Aug 2008 16:45:57 -0400
 >
 >> Speaking of stateless data placement.  Assume you have a page or set
 >> of pages allocated by a network driver which contain exactly the data
 >> a block driver is interested in to fulfill a read request (eg, the NIC
 >> understands the protocol just well enough to split headers).  Is it
 >> possible in the block driver to simply replace the pages that are
 >> attached to the buf with pages allocated by the network driver?
 >>
 >> It was my impression that the pages associated with a buf are in
 >> fairly magical states and that you cannot replace them.
 >
 > This, if true, would be quite easy to rectify.

That's great news.

The reason I think this is because a few months ago, I tried to make
the AOE block driver zero-copy on read.  I modified the myri10ge
ethernet driver and firmware to split AOE headers, so that the AOE
read data started nicely aligned in a page allocated by myri10ge.
(this obviously only works for for jumbo MTUs..).  This part was
trivial, but I got bogged down trying to figure out how to replace the
buf associated pages in the AOE driver, as they seemed to be in
various states of entanglement with the LRU and page caches.

I'm more of a network driver guy, and my lack of understanding of the
block layer and page cache probably made me give up too quickly.  I'll
dust off this work and ask for help.

Thanks,

Drew
