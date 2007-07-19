From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Socket Buffers and Memory Managment
Date: Thu, 19 Jul 2007 13:08:26 +0400
Message-ID: <20070719090826.GA14860@2ka.mipt.ru>
References: <20070717204129.79e7fe0d@oldman> <261750.43078.qm@web82911.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: vinay ravuri <vinaynyc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38461 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbXGSJIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 05:08:34 -0400
Content-Disposition: inline
In-Reply-To: <261750.43078.qm@web82911.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Wed, Jul 18, 2007 at 11:51:03PM -0700, vinay ravuri (vinaynyc@yahoo.com) wrote:
> How about the following approach:
> 
> I allocate an skb of 0 bytes and replace data element
> of skb struct (i.e. skb.data = addr_given_by_hw) when
> the h/w interrupts me with a packet.  I register for a
> destructor for this skb and when the kernel is ready
> to free the skb, I make sure that my free is invoked -
> Ofcourse this is assuming that their is a facility in
> linux socket buffers to be able to do destructors.  Is
> this approach a viable, if so, are any gottcha's?

It will not work, since kfree_skb() eventually tries to free skb->head
into kmem cache, so you will need to hack kfree_skb() not to try to
release that data at all. Likely the best zero-copy approach in your
case is to use frag_list, but be ready that your netwrok will regularily
stall - when hardware buffers are all in use and not yet freed, you will
not be able to send/receive new packets, although amount of memory will
allow that.

> -Vinay

-- 
	Evgeniy Polyakov
