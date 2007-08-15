From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Wed, 15 Aug 2007 20:51:58 +0200
Message-ID: <2cbda24e96a49c3ab7cf7039c515f9fc@kernel.crashing.org>
References: <46BCC26B.6080600@redhat.com> <46BB46B2.60808@redhat.com> <20070809134150.GA14890@shell.boston.redhat.com> <2708.1186737826@redhat.com> <7680.1186822071@redhat.com> <46BFFDBD.6080804@redhat.com> <46C140DD.3060509@yahoo.com.au>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com,
	David Howells <dhowells@redhat.com>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:42428 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754477AbXHOSwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 14:52:55 -0400
In-Reply-To: <46C140DD.3060509@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Well if there is only one memory location involved, then smp_rmb() 
> isn't
> going to really do anything anyway, so it would be incorrect to use it.

rmb() orders *any* two reads; that includes two reads from the same
location.

> Consider that smp_rmb basically will do anything from flushing the
> pipeline to invalidating loads speculatively executed out of order. 
> AFAIK
> it will not control the visibility of stores coming from other CPUs 
> (that
> is up to the cache coherency).

The writer side should typically use wmb() whenever the reader side
uses rmb(), sure.


Segher

