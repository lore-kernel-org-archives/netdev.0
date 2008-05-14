From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 01:52:23 +0100
Message-ID: <20080514005223.GE27483@shareable.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760580AbYENAwt@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080513205114.GA16489@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> > Where is the best place to look at client<->server protocol?
> 
> Hmm, in sources I think, I need to kick myself to write a somewhat good
> spec for the next release.
> 
> Basically protocol contains of fixed sized header (struct netfs_cmd) and
> attached data [..]

I feel you have glossed over the more difficult parts of transactions
and cache coherency etc. with this brief summary ;-)

> > Are you planning to support the case where the server filesystem dataset 
> > does not fit entirely on one server?
> 
> Sure. First by allowing whole object to be placed on different servers
> (i.e. one subdir is on server1 and another on server2), probably in the
> future there will be added support for the same object being distributed
> to different servers (i.e. half of the big file on server1 and another
> half on server2).
> 
> > What is your opinion of the Paxos algorithm?
> 
> It is slow. But it does solve failure cases.
> So far POHMELFS does not work as distributed filesystem, so it should
> not care about it at all, i.e. at most in the very nearest future it
> will just have number of acceptors in paxos terminology (metadata
> servers in others) without need for active dynamical reconfiguration,
> so protocol will be greatly reduced, with addition of dynamical
> metadata cluster extension protocol will have to be extended.

Yours does sound a very interesting project.  Do you know how it
compares with NFSv4 for performance?  I think that has some similar
caching abilities?  I think CRFS should be similar.

> As practice shows, the smaller and simpler initial steps are, the better
> results eventually become :)

I think you are right.  I am struggling with the opposite approach
(too big steps, trying to be too clever with algorithms) on a similar
project!  That said, I did try simpler steps earlier, and it worked
but showed a lot of tricky problems.

Fwiw, I've been working on what started as a distributed database that
is coming to be a filesystem too.  It has many qualities of both,
hopefully the best ones.  I'm aiming for high LAN file performance
similar to what you report with POHMELFS and would expect from any
modern fs, while also supporting database style transactions and
coherent queries, in a self-organising distributed system that handles
LAN/WAN/Internet each at their best.  Mention of Paxos stirred me to
reply - a relative of that is in there somewhere.  I have a long way
to go before a release.

If anyone is working on something similar, I would be delighted to
hear from them.

It scares me that I'm actually trying to do this.  But very exciting
it is too.

It seems there's quite a bit of interesting work on Linux in this area
right now, with BTRFS and CRFS too.

-- Jamie
