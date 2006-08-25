From: David Miller <davem@davemloft.net>
Subject: Re: [take13 1/3] kevent: Core files.
Date: Fri, 25 Aug 2006 00:01:06 -0700 (PDT)
Message-ID: <20060825.000106.30184424.davem@davemloft.net>
References: <20060824200322.GA19533@infradead.org>
	<20060825054815.GC16504@2ka.mipt.ru>
	<20060824232024.0d230823.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, hch@infradead.org,
	linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33450
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751034AbWHYHBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 03:01:05 -0400
To: akpm@osdl.org
In-Reply-To: <20060824232024.0d230823.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Thu, 24 Aug 2006 23:20:24 -0700

> On Fri, 25 Aug 2006 09:48:15 +0400
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > kmalloc is really slow actually - it always shows somewhere on top 
> > in profiles and brings noticeble overhead
> 
> It shouldn't.  Please describe the workload and send the profiles.

Not that I can account for the problem in this specific case, in my
experience cutting down kmalloc() calls matters a _lot_ performance
wise.

For example, this is why we allocate TCP sockets as one huge blob
instead of 3 seperate allocations (generic socket, IP socket, TCP
socket).

In fact, one of the remaining performance issues in IPSEC rule
creation is that we allocate seperately hunks of memory for the rule's
encryption state, the optional hash algorithm state, etc.
