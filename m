From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression
 with tbench
Date: Wed, 14 Nov 2007 10:33:54 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0711141028390.12531@schroedinger.engr.sgi.com>
References: <20071114.031022.183117678.davem@davemloft.net>
 <20071114114844.GA13927@gondor.apana.org.au> <200711141102.11477.nickpiggin@yahoo.com.au>
 <20071114.041008.146131045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nickpiggin@yahoo.com.au, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:43324 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752759AbXKNSdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 13:33:55 -0500
In-Reply-To: <20071114.041008.146131045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Nov 2007, David Miller wrote:

> > Still interested to know why SLAB didn't see the same thing...
> 
> Yes, I wonder why too.  I bet objects just got packed differently.

The objects are packed tightly in SLUB and SLUB can allocate smaller 
objects (minimum is 8 SLAB mininum is 32).

On free a SLUB object goes directly back to the slab where it came from. 
We have no queues in SLUB so we use the first word of the object as a 
freepointer. In SLAB the objects first go onto queues and then are drained 
later into the slab. On free in SLAB there is usually no need to touch the 
object itself. The object pointer is simply moved onto the queue (works 
well in SMP, in NUMA we have overhead identifying the queue and 
overhead due to the number of queues needed).

