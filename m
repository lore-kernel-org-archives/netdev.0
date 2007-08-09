From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Thu, 09 Aug 2007 12:54:10 -0400
Message-ID: <46BB46B2.60808@redhat.com>
References: <20070809134150.GA14890@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44930 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966024AbXHIRAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 13:00:15 -0400
In-Reply-To: <20070809134150.GA14890@shell.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook wrote:
> From: Chris Snook <csnook@redhat.com>
> 
> Make atomic_read() volatile on frv.  This ensures that busy-waiting
> for an interrupt handler to change an atomic_t won't get compiled to an
> infinite loop, consistent with SMP architectures.

To head off the criticism, I admit this is an oversimplification, and true 
busy-waiters should be using cpu_relax(), which contains a barrier.  As 
discussed in recent threads, there are other cases which can be optimized by 
removing the need for a barrier, and having behavior consistent with 
architectures where the benefit is more profound is also valuable.

	-- Chris
