From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 13 Mar 2007 11:08:27 +0100
Message-ID: <200703131108.27435.dada1@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <20070302085246.GA30951@2ka.mipt.ru> <20070313093248.GA14221@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:33020 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753212AbXCMKIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 06:08:23 -0400
In-Reply-To: <20070313093248.GA14221@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 March 2007 10:32, Evgeniy Polyakov wrote:
> On Fri, Mar 02, 2007 at 11:52:47AM +0300, Evgeniy Polyakov 
(johnpol@2ka.mipt.ru) wrote:
> So, I ask network developers about testing environment for socket lookup
> benchmarking. What would be the best test case to determine performance
> of the lookup algo? Is it enough to replace algo and locking and create
> say one million of connections and try to run trivial web server (that
> is what I'm going to test if there will not be any better suggestion,
> but I only have single-core athlon 64 with 1gb of ram as a test bed and
> two core duo machines as generators, probably I can use one of them as a
> test machine too. They have gigabit adapters and aree connected over
> gigabit switch)?

One million concurrent sockets on your machines will be tricky :)

$ egrep "(filp|dent|^TCP|sock_inode_cache)" /proc/slabinfo |cut -c1-40
TCP                   12     14   1152  
sock_inode_cache     423    430    384  
dentry_cache       36996  47850    132  
filp                4081   4680    192  

that means at the minimum 1860 bytes of LOWMEM per tcp socket on 32bit kernel, 
(2512 bytes on a 64bit kernel)

I had one bench program but apparently I lost it :(
It was able to open long lived sockets, (one million if enough memory), and 
was generating kind of random trafic on all sockets. damned.
The 'server' side had to listen to many (>16) ports because of the 65536 
limit.
