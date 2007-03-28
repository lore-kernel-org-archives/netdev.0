From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Established connections hash function
Date: Wed, 28 Mar 2007 16:52:55 +0200
Message-ID: <20070328145255.GA7466@one.firstfloor.org>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <p73lkhi6aj7.fsf@bingen.suse.de> <EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON> <200703281129.43783.ak@suse.de> <20070328104505.GA18748@2ka.mipt.ru> <p73y7lh316u.fsf@bingen.suse.de> <20070328155047.4112fb47.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, nikb@webmaster.com,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53430 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152AbXC1OxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 10:53:00 -0400
Content-Disposition: inline
In-Reply-To: <20070328155047.4112fb47.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2007 at 03:50:47PM +0200, Eric Dumazet wrote:
> 1) We can now use "struct timespec" to get more bits in init_std_data()

That would be a good change, but i don't think it would help that much.
If you know the hardware (e.g. webhost farms tend to have quite
predictive kit) and the kernel binary and the boot offset from
the timestamp you can probably guess the range of ns pretty closely
(let's say down to a few ms). With that it's a small range to search. 

> 2) tcp ehash salt is initialized at first socket creation, not boot time. Maybe we have more available entropy at this point.

Sockets are created early too. It would be a little better, but probably
not much. 

The only true random seed is disk, keyboard/mouse and previous state. previous
state is typically a relatively late init script, probably after the first
socket.  Servers tend to have no disk/mouse activity.

Disk may work if you manage to put it after the root mount, but you
lose on diskless systems. e.g. if the nfsd is built in that wouldn't
work though because it would create sockets before that.

Getting entropy from network interrupts would avoid the the diskless
issue, but people are paranoid about that.


> 3) We dont want to be 'totally secure'. We only want to raise the level, and eventually see if we have to spend more time on this next year(s). AFAIK we had two different reports from people being hit by the flaw of previous hash. Not really a critical issue.

Yes, but you probably want a complexity of at least 10^5-10^6 to be any
useful. I don't think you will get that early in boot from random
unless you use hardware support.

> 
> 4) We could add a hard limit on the length of one chain. Even if the bad guys discover a flaw, it wont hurt too much.

Or just use the trie?  It has other advantages too :)

-Andi

