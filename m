From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 7/7] cxgb3 - Add SW LRO support
Date: Mon, 26 Feb 2007 16:55:29 -0800
Message-ID: <45E38181.5030409@chelsio.com>
References: <20070225004423.20903.17036.stgit@localhost.localdomain> <20070226051304.GA13626@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, divy@chelsio.com,
	jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.22.49.110] ([12.22.49.110]:29448 "EHLO stargate.chelsio.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S965045AbXB0A6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 19:58:41 -0500
In-Reply-To: <20070226051304.GA13626@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Sat, Feb 24, 2007 at 04:44:23PM -0800, divy@chelsio.com wrote:
>   
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Add all-in-sw lro support.
>>     
>
> Doing this in a LLDD doesn't sound like a good idea.  Have you
> tried doing this in the core networking code instead?
>   

We have not tried to implement LRO in the core networking code.
Today, the available API for a driver to pass packets up is 
netif_receive_skb/netif_rx.
Our implementation coalesces pages, then gets a skb to point at the 
pages and passes it up to the stack.
LRO in the core networking code would require adding methods to pass up 
data segments in addition to skbs.
HW might also be able to assist LRO by identifying the session an 
incoming packet belongs to,
thus avoiding the session lookup. The API should also allow for the 
driver to indicate such info.

Cheers,
Divy
