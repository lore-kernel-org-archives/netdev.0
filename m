From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Handling receive packets with limited buffer space
Date: Sat, 20 Mar 2010 16:01:40 +0100
Message-ID: <8739zvca0b.fsf@basil.nowhere.org>
References: <20100319094118.GA30249@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Amit Uttamchandani <amit.uttam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54000 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab0CTPBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 11:01:42 -0400
In-Reply-To: <20100319094118.GA30249@debian> (Amit Uttamchandani's message of "Fri, 19 Mar 2010 02:41:18 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amit Uttamchandani <amit.uttam@gmail.com> writes:

> In my modified ethoc.c driver, I am using only one receive buffer
> descriptor due to limited space. This works fairly well for small
> packets (arp, pings, etc.).
>
> However, doing a 'wget' and downloading a file causes lots of drops and
> thus results in a terminated connection.
>
> How do I go about dealing with this? I tried stopping the queue
> (netif_stop_queue) while I'm processing the rx skb and then resuming it
> once I'm done, but this did not seem to help.
>
> Any ideas on this?

You'll need to allocate a new skb and copy into it before
passing the data up the stack.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
