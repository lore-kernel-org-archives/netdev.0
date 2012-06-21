From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Bug in net/ipv6/ip6_fib.c:fib6_dump_table()
Date: Fri, 22 Jun 2012 01:50:56 +0400
Message-ID: <20120621215056.GA24908@ms2.inr.ac.ru>
References: <CAATkVEzTxT6d5nzt_qwCuFWM-WcN8hdhjGxFRPXJ4=L35wKbGw@mail.gmail.com> <4FE37783.9000409@akamai.com> <1340310469.4604.6702.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Hunt <johunt@akamai.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	Debabrata Banerjee <dbavatar@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340310469.4604.6702.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 21, 2012 at 10:27:49PM +0200, Eric Dumazet wrote:
> Looking at this code, it lacks proper synchronization
> between tree updaters and tree walkers.
> 
> fib6_walker_lock rwlock is not enough to prevent races.

Hmm. As author of this weird code, I must say I honestly believed it was correct.
At least I tried. :-)


What's about 2bec5a336.., it does not look reasonable.
The idea was that when you change tree, you fixup sleeping walkers, moving
their location in tree to correct point. So, walkers must not have any stale pointers
at any times (except when you under table write lock) and no skips/counts are required.
I remember how damn difficult was it to make this right (well, sorry, if it is not yet :-)),
so that understand that if some update is forgotten or done incorrectly, it is not so easy to find,
but it is definitely worth of efforts.

Alexey
