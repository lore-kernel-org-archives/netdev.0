From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Socket Buffers and Memory Managment
Date: Thu, 19 Jul 2007 09:10:41 +0100
Message-ID: <20070719091041.06f29789@oldman>
References: <20070717204129.79e7fe0d@oldman>
	<261750.43078.qm@web82911.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vinay ravuri <vinaynyc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60795 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758121AbXGSIeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 04:34:19 -0400
In-Reply-To: <261750.43078.qm@web82911.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jul 2007 23:51:03 -0700 (PDT)
vinay ravuri <vinaynyc@yahoo.com> wrote:

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
> 
> -Vinay

You need to use frag list for that since upper layers expect to
be able to use that data area for normal use, ie bridging/routing, etc.
Also access to data area would be non-cached so you want to make
sure it is only accessed once.

But how will you handle a slow receiver where all the skb's end up
staying queued. Won't you exhaust your packet memory.
