From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Socket Buffers and Memory Managment
Date: 20 Jul 2007 13:50:30 +0200
Message-ID: <p73tzrzuwe1.fsf@bingen.suse.de>
References: <20070717204129.79e7fe0d@oldman>
	<261750.43078.qm@web82911.mail.mud.yahoo.com>
	<20070719090826.GA14860@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vinay ravuri <vinaynyc@yahoo.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:58252 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751527AbXGTKzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 06:55:32 -0400
In-Reply-To: <20070719090826.GA14860@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:

> Hi.
> 
> On Wed, Jul 18, 2007 at 11:51:03PM -0700, vinay ravuri (vinaynyc@yahoo.com) wrote:
> > How about the following approach:
> > 
> > I allocate an skb of 0 bytes and replace data element
> > of skb struct (i.e. skb.data = addr_given_by_hw) when
> > the h/w interrupts me with a packet.  I register for a
> > destructor for this skb and when the kernel is ready
> > to free the skb, I make sure that my free is invoked -
> > Ofcourse this is assuming that their is a facility in
> > linux socket buffers to be able to do destructors.  Is
> > this approach a viable, if so, are any gottcha's?
> 
> It will not work, since kfree_skb() eventually tries to free skb->head
> into kmem cache,

And in addition if the skbuff is ever passed towards the socket
layer the destructor will be overwritten

-Andi
