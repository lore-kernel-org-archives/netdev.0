From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 11:57:56 +0400
Message-ID: <20080514075756.GC28330@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <20080514005223.GE27483@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514005223.GE27483@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2008 at 01:52:23AM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> I feel you have glossed over the more difficult parts of transactions
> and cache coherency etc. with this brief summary ;-)

It was (and is) also a different time zone here :)

> Yours does sound a very interesting project.  Do you know how it
> compares with NFSv4 for performance?  I think that has some similar
> caching abilities?  I think CRFS should be similar.

NFSv4 does not use similar caching scheme, but it has interesting
batching abilities for bulk data transfer. CRFS was originally a source
of inspiration for this project (before it was opened, we had some talk
with Zach Brown, so I decided that it worth deeper investigation and
started this FS). CRFS performance is also very good, but the fact, that
it is only limited to BTRFS server seriously limits its usage imho.

> > As practice shows, the smaller and simpler initial steps are, the better
> > results eventually become :)
> 
> I think you are right.  I am struggling with the opposite approach
> (too big steps, trying to be too clever with algorithms) on a similar
> project!  That said, I did try simpler steps earlier, and it worked
> but showed a lot of tricky problems.

The more we develop, more problems arises, so it is possible (and I had
such situation), when very complex, but solvable problem, during
development translates into multiple problems of the same complexity,
which takes more and more time... Essentially this can be solved, until
something is dropped and added when other things are completed.

For example there is a really interesting lockless algorithm for storing
path cache in the POHMELFS, but implementation is really complex, so I
used much simler tree based one, and things scale good even with it.

> Fwiw, I've been working on what started as a distributed database that
> is coming to be a filesystem too.  It has many qualities of both,
> hopefully the best ones.  I'm aiming for high LAN file performance
> similar to what you report with POHMELFS and would expect from any
> modern fs, while also supporting database style transactions and
> coherent queries, in a self-organising distributed system that handles
> LAN/WAN/Internet each at their best.  Mention of Paxos stirred me to
> reply - a relative of that is in there somewhere.  I have a long way
> to go before a release.

Depending on what to call a release :)

> If anyone is working on something similar, I would be delighted to
> hear from them.

I belive that (only block?) FS which exports its structure in database
accessible way, i.e. ability to search objects not only by name key and
assign that new keys similar to how it is done in database, but not via
assign_xattr(search(name)), is a very interesting and useful approach.
Also the more I follow general purpose fs developments, the more I
become sure that they (general purpose) will never be the best on any
given workload, and instead special purpose (like databasefs or
whatever) filesystems will get the niche. IMHO of course.

> It scares me that I'm actually trying to do this.  But very exciting
> it is too.

Scares problems which we can not solve, this one kind of increases
adrenalin level :)

> It seems there's quite a bit of interesting work on Linux in this area
> right now, with BTRFS and CRFS too.

Yeah, probably this is time to move further in given area, so lots of
interesting new developments.

-- 
	Evgeniy Polyakov
