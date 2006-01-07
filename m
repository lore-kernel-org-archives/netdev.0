From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 23:10:54 -0800 (PST)
Message-ID: <20060106.231054.43576567.davem@davemloft.net>
References: <200601062157.42470.ak@suse.de>
	<20060106.161721.124249301.davem@davemloft.net>
	<200601070209.02157.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, dada1@cosmosbay.com, alan@lxorguk.ukuu.org.uk,
	torvalds@osdl.org, linux-kernel@vger.kernel.org,
	dipankar@in.ibm.com, manfred@colorfullife.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751494AbWAGHLV@vger.kernel.org>
To: ak@suse.de
In-Reply-To: <200601070209.02157.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Sat, 7 Jan 2006 02:09:01 +0100

> I always disliked the per chain spinlocks even for other hash tables like
> TCP/UDP multiplex - it would be much nicer to use a much smaller separately 
> hashed lock table and save cache. In this case the special case of using
> a one entry only lock hash table makes sense.

I used to think they were a great technique.  But in each case I
thought they could be applied, better schemes have come along.
In the case of the page cache we went to a per-address-space tree,
and here in the routing cache we went to RCU.

There are RCU patches around for the TCP hashes and I'd like to
put those in at some point as well.  In fact, they'd be even
more far reaching since Arnaldo abstracted away the socket
hashing stuff into an inet_hashtables subsystem.
