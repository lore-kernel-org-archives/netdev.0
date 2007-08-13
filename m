From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Mon, 13 Aug 2007 02:44:13 -0400
Message-ID: <46BFFDBD.6080804@redhat.com>
References: <46BCC26B.6080600@redhat.com> <46BB46B2.60808@redhat.com> <20070809134150.GA14890@shell.boston.redhat.com> <2708.1186737826@redhat.com> <7680.1186822071@redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:33608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967818AbXHMGuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:50:37 -0400
In-Reply-To: <7680.1186822071@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells wrote:
> Chris Snook <csnook@redhat.com> wrote:
> 
>> cpu_relax() contains a barrier, so it should do the right thing.  For non-smp
>> architectures, I'm concerned about interacting with interrupt handlers.  Some
>> drivers do use atomic_* operations.
> 
> I'm not sure that actually answers my question.  Why not smp_rmb()?
> 
> David

I would assume because we want to waste time efficiently even on non-smp 
architectures, rather than frying the CPU or draining the battery.  Certain 
looping execution patterns can cause the CPU to operate above thermal design 
power.  I have fans on my workstation that only ever come on when running 
LINPACK, and that's generally memory bandwidth-bound.  Just imagine what happens 
when you're executing the same few non-serializing instructions in a tight loop 
without ever stalling on memory fetches, or being scheduled out.

If there's another reason, I'd like to hear it too, because I'm just guessing here.

	-- Chris
