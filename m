From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 13 Mar 2007 13:24:07 +0300
Message-ID: <20070313102407.GA31940@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <20070302085246.GA30951@2ka.mipt.ru> <20070313093248.GA14221@2ka.mipt.ru> <200703131108.27435.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60329 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753219AbXCMKZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 06:25:52 -0400
Content-Disposition: inline
In-Reply-To: <200703131108.27435.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 13, 2007 at 11:08:27AM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Tuesday 13 March 2007 10:32, Evgeniy Polyakov wrote:
> > On Fri, Mar 02, 2007 at 11:52:47AM +0300, Evgeniy Polyakov 
> (johnpol@2ka.mipt.ru) wrote:
> > So, I ask network developers about testing environment for socket lookup
> > benchmarking. What would be the best test case to determine performance
> > of the lookup algo? Is it enough to replace algo and locking and create
> > say one million of connections and try to run trivial web server (that
> > is what I'm going to test if there will not be any better suggestion,
> > but I only have single-core athlon 64 with 1gb of ram as a test bed and
> > two core duo machines as generators, probably I can use one of them as a
> > test machine too. They have gigabit adapters and aree connected over
> > gigabit switch)?
> 
> One million concurrent sockets on your machines will be tricky :)
> 
> $ egrep "(filp|dent|^TCP|sock_inode_cache)" /proc/slabinfo |cut -c1-40
> TCP                   12     14   1152  
> sock_inode_cache     423    430    384  
> dentry_cache       36996  47850    132  
> filp                4081   4680    192  
> 
> that means at the minimum 1860 bytes of LOWMEM per tcp socket on 32bit kernel, 
> (2512 bytes on a 64bit kernel)
> 
> I had one bench program but apparently I lost it :(
> It was able to open long lived sockets, (one million if enough memory), and 
> was generating kind of random trafic on all sockets. damned.
> The 'server' side had to listen to many (>16) ports because of the 65536 
> limit.

Yep, I was too optimistic about my hardware - getting size of the tcp
socket it is impossible to even create such amount of them with 1 or 2 gb of
ram.

Well, I can run additional tests in userspace (ideally with hugetlb support, 
but given that both socket hash table and my algo use essentially the same
amount of ram it should not matter) with more precise analysis...

And just send a patch with detailed description.

-- 
	Evgeniy Polyakov
