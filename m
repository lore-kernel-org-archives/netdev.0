From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Tue, 14 Aug 2007 18:45:12 -0400
Message-ID: <46C23078.4040109@redhat.com>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934398AbXHNWpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 18:45:54 -0400
In-Reply-To: <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter wrote:
> On Thu, 9 Aug 2007, Chris Snook wrote:
> 
>> This patchset makes the behavior of atomic_read uniform by removing the
>> volatile keyword from all atomic_t and atomic64_t definitions that currently
>> have it, and instead explicitly casts the variable as volatile in
>> atomic_read().  This leaves little room for creative optimization by the
>> compiler, and is in keeping with the principles behind "volatile considered
>> harmful".
> 
> volatile is generally harmful even in atomic_read(). Barriers control
> visibility and AFAICT things are fine.

But barriers force a flush of *everything* in scope, which we generally don't 
want.  On the other hand, we pretty much always want to flush atomic_* 
operations.  One way or another, we should be restricting the volatile behavior 
to the thing that needs it.  On most architectures, this patch set just moves 
that from the declaration, where it is considered harmful, to the use, where it 
is considered an occasional necessary evil.

See the resubmitted patchset, which also puts a cast in the atomic[64]_set 
operations.

	-- Chris
