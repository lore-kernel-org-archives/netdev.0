From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Tue, 14 Aug 2007 15:51:23 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0708141550001.490@schroedinger.engr.sgi.com>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <46C23078.4040109@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:53259 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765147AbXHNWvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 18:51:24 -0400
In-Reply-To: <46C23078.4040109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Aug 2007, Chris Snook wrote:

> But barriers force a flush of *everything* in scope, which we generally don't
> want.  On the other hand, we pretty much always want to flush atomic_*
> operations.  One way or another, we should be restricting the volatile
> behavior to the thing that needs it.  On most architectures, this patch set
> just moves that from the declaration, where it is considered harmful, to the
> use, where it is considered an occasional necessary evil.

Then we would need

	atomic_read()

and

	atomic_read_volatile()

atomic_read_volatile() would imply an object sized memory barrier before 
and after?
