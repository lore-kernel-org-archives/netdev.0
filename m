From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 10:04:52 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0303271002420.29205-100000@home.transmeta.com>
References: <20030327.095537.26269606.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shmulik.hen@intel.com, <dane@aiinet.com>,
   <bonding-devel@lists.sourceforge.net>,
   <bonding-announce@lists.sourceforge.net>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>, <linux-net@vger.kernel.org>,
   <mingo@redhat.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030327.095537.26269606.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Thu, 27 Mar 2003, David S. Miller wrote:
> 
>    I do agree that we should obviously not run bottom halves with
>    interrupts disabled
>    
> Ok, so can we add a:
> 
> 	if (irqs_disabled())
> 		BUG();
> 
> check to do_softirq()?

I'd suggest making it a counting warning (with a static counter per
local-bh-enable macro expansion) and adding it to local_bh_enable() -
otherwise it will only BUG()  when the (potentially rare) condition
happens - instead of always giving a nice backtrace of exact problem 
spots.

		Linus
