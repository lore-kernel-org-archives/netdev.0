From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Thu, 15 Dec 2005 00:21:20 -0800 (PST)
Message-ID: <20051215.002120.133621586.davem@davemloft.net>
References: <20051215033937.GC11856@waste.org>
	<20051214.203023.129054759.davem@davemloft.net>
	<Pine.LNX.4.58.0512142318410.7197@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, ak@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161076AbVLOI3c@vger.kernel.org>
To: sri@us.ibm.com
In-Reply-To: <Pine.LNX.4.58.0512142318410.7197@w-sridhar.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 14 Dec 2005 23:37:37 -0800 (PST)

> Instead, you seem to be suggesting in_emergency to be set dynamically
> when we are about to run out of ATOMIC memory. Is this right?

Not when we run out, but rather when we reach some low water mark, the
"critical sockets" would still use GFP_ATOMIC memory but only
"critical sockets" would be allowed to do so.

But even this has faults, consider the IPSEC scenerio I mentioned, and
this applies to any kind of encapsulation actually, even simple
tunneling examples can be concocted which make the "critical socket"
idea fail.

The knee jerk reaction is "mark IPSEC's sockets critical, and mark the
tunneling allocations critical, and... and..."  well you have
GFP_ATOMIC then my friend.

In short, these "seperate page pool" and "critical socket" ideas do
not work and we need a different solution, I'm sorry folks spent so
much time on them, but they are heavily flawed.
