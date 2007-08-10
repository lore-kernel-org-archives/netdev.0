From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Fri, 10 Aug 2007 15:54:19 -0400
Message-ID: <46BCC26B.6080600@redhat.com>
References: <46BB46B2.60808@redhat.com> <20070809134150.GA14890@shell.boston.redhat.com> <2708.1186737826@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46908 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938642AbXHJTyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 15:54:40 -0400
In-Reply-To: <2708.1186737826@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells wrote:
> Chris Snook <csnook@redhat.com> wrote:
> 
>> To head off the criticism, I admit this is an oversimplification, and true
>> busy-waiters should be using cpu_relax(), which contains a barrier.
> 
> Why would you want to use cpu_relax()?  That's there to waste time efficiently,
> isn't it?  Shouldn't you be using smp_rmb() or something like that?
> 
> David

cpu_relax() contains a barrier, so it should do the right thing.  For 
non-smp architectures, I'm concerned about interacting with interrupt 
handlers.  Some drivers do use atomic_* operations.

	-- Chris
