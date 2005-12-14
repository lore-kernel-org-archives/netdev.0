From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 19:41:47 +0100
Message-ID: <20051214184147.GO23384@wotan.suse.de>
References: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com> <20051214092228.GC18862@brahms.suse.de> <1134582945.8698.17.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964880AbVLNSlw@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <1134582945.8698.17.camel@w-sridhar2.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Here we are assuming that the pre-allocated critical page pool is big enough
> to satisfy the requirements of all the critical sockets.

That seems like a lot of assumptions. Is it really better than the 
existing GFP_ATOMIC which works basically the same?  It has a lot
more users that compete true, but likely the set of GFP_CRITICAL users
would grow over time too and it would develop the same problem.

I think if you really want to attack this problem and improve
over the GFP_ATOMIC "best effort in smaller pool" approach you should
probably add real reservations. And then really do a lot of testing
to see if it actually helps.

-Andi
