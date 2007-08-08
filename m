From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH RFC]: napi_struct V6
Date: Wed, 8 Aug 2007 07:06:28 -0400
Message-ID: <20070808070628.284d805c@oldman>
References: <20070807.215432.09951753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, hadi@cyberus.ca,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36637 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbXHHLGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 07:06:52 -0400
In-Reply-To: <20070807.215432.09951753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 07 Aug 2007 21:54:32 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> Changes since V5:
> 
> 1) Revert unnecessary TX locking changes in bnx2 and tg3
> 
> 2) ++i
> 
> This is probably what I'll check into my net-2.6.24 tree
> 
> Thanks.
> 
> [NET]: Make NAPI polling independant of struct net_device objects.
> 
> Several devices have multiple independant RX queues per net
> device, and some have a single interrupt doorbell for several
> queues.
> 
> In either case, it's easier to support layouts like that if the
> structure representing the poll is independant from the net
> device itself.
> 
> The signature of the ->poll() call back goes from:
> 
> 	int foo_poll(struct net_device *dev, int *budget)
> 
> to
> 
> 	int foo_poll(struct napi_struct *napi, int budget)
> 
> The caller is returned the number of RX packets processed (or
> the number of "NAPI credits" consumed if you want to get
> abstract).  The callee no longer messes around bumping
> dev->quota, *budget, etc. because that is all handled in the
> caller upon return.
> 
> The napi_struct is to be embedded in the device driver private data
> structures.
> 
> Furthermore, it is the driver's responsibility to disable all NAPI
> instances in it's ->stop() device close handler.  Since the
> napi_struct is privatized into the driver's private data structures,
> only the driver knows how to get at all of the napi_struct instances
> it may have per-device.
> 
> With lots of help and suggestions from Rusty Russell.
> 
> [ Ported to current tree and all drivers converted.  -DaveM ]
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>


Thanks for doing all this. Looks great.
Documentation of NAPI still needs more work. I'll take a start at getting
net_device docbook format cleaned up, then start on a redo of the API
documentation.  
