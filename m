From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Fri, 28 Feb 2014 14:31:27 +0100
Message-ID: <20140228133127.GT22728@two.firstfloor.org>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
 <87fvn3dd9i.fsf@tassilo.jf.intel.com>
 <1393568072.26794.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([193.170.194.197]:35123 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbaB1Nb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 08:31:29 -0500
Content-Disposition: inline
In-Reply-To: <1393568072.26794.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Right, so I cooked this instead :
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=363ec392352e55c61ce2799c3f15f89f9429bba7
> 
> Is this OK or do you see a problem with this ?

It seems mostly ok. I assume the compiler optimizes the constant do_div to a
multiplication?

I'm not sure it's better than ktime() if it works. So it may be still
better to have some global flag that says "ktime is slow" and
qualify it on that.  But that would need changing the timer
subsystem.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
