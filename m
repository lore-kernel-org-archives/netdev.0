From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: RE: [PATCH 9/24] make atomic_read() behave consistently on ia64
Date: Fri, 10 Aug 2007 16:09:32 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708101607130.30176@woody.linux-foundation.org>
References: <20070809135107.GA15985@shell.boston.redhat.com><617E1C2C70743745A92448908E030B2A02213B3C@scsmsx411.amr.corp.intel.com><46BCC1AF.5050204@redhat.com><617E1C2C70743745A92448908E030B2A0224C777@scsmsx411.amr.corp.intel.com>
 <jewsw3oyl8.fsf@sykes.suse.de> <617E1C2C70743745A92448908E030B2A0224C88B@scsmsx411.amr.corp.intel.com>
 <46BCE9F8.4060009@redhat.com>
 <617E1C2C70743745A92448908E030B2A0224C8D7@scsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Chris Snook <csnook@redhat.com>, Andreas Schwab <schwab@suse.de>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: "Luck, Tony" <tony.luck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43730 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754930AbXHJXKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 19:10:39 -0400
In-Reply-To: <617E1C2C70743745A92448908E030B2A0224C8D7@scsmsx411.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 10 Aug 2007, Luck, Tony wrote:
> 
> Here are the functions in which they occur in the object file. You
> may have to chase down some inlining to find the function that
> actually uses atomic_*().

Could you just make the "atomic_read()" and "atomic_set()" functions be 
inline functions instead?

That way you get nice compiler warnings when you pass the wrong kind of 
object around.  So

	static void atomic_set(atomic_t *p, int value)
	{
		*(volatile int *)&p->value = value;
	}

	static int atomic_read(atomic_t *p)
	{
		return *(volatile int *)&p->value;
	}

etc...

		Linus
