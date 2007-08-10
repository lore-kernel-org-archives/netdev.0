From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 9/24] make atomic_read() behave consistently on ia64
Date: Fri, 10 Aug 2007 19:15:42 -0400
Message-ID: <46BCF19E.5000702@redhat.com>
References: <20070809135107.GA15985@shell.boston.redhat.com><617E1C2C70743745A92448908E030B2A02213B3C@scsmsx411.amr.corp.intel.com><46BCC1AF.5050204@redhat.com><617E1C2C70743745A92448908E030B2A0224C777@scsmsx411.amr.corp.intel.com> <jewsw3oyl8.fsf@sykes.suse.de> <617E1C2C70743745A92448908E030B2A0224C88B@scsmsx411.amr.corp.intel.com> <46BCE9F8.4060009@redhat.com> <617E1C2C70743745A92448908E030B2A0224C8D7@scsmsx411.amr.corp.intel.com> <alpine.LFD.0.999.0708101607130.30176@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luck, Tony" <tony.luck@intel.com>,
	Andreas Schwab <schwab@suse.de>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754040AbXHJXQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 19:16:17 -0400
In-Reply-To: <alpine.LFD.0.999.0708101607130.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> 
> On Fri, 10 Aug 2007, Luck, Tony wrote:
>> Here are the functions in which they occur in the object file. You
>> may have to chase down some inlining to find the function that
>> actually uses atomic_*().
> 
> Could you just make the "atomic_read()" and "atomic_set()" functions be 
> inline functions instead?
> 
> That way you get nice compiler warnings when you pass the wrong kind of 
> object around.  So
> 
> 	static void atomic_set(atomic_t *p, int value)
> 	{
> 		*(volatile int *)&p->value = value;
> 	}
> 
> 	static int atomic_read(atomic_t *p)
> 	{
> 		return *(volatile int *)&p->value;
> 	}
> 
> etc...

I'll do this for the whole patchset.  Stay tuned for the resubmit.

	-- Chris
