From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 19:00:53 +0400
Message-ID: <20080514150052.GA15826@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sage Weil <sage@newdream.net>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514143105.GB14987@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2008 at 03:31:05PM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> > If we are talking about agregate parallel perfromance, then its basic
> > protocol with 2 messages is (probably) optimal, but still I'm not
> > convinced, that 2 messages case is a good choise, I want one :)
> 
> Look up "one-phase commit" or even "zero-phase commit".  (The
> terminology is cheating a bit.)  As I've understood it, all commit
> protocols have a step where each node guarantees it can commit if
> asked and node failure at that point does not invalidate the guarantee
> if the node recovers (if it can't maintain the guarantee, the node
> doesn't recover in a technical sense and a higher level protocol may
> reintegrate the node).  One/zero-phase commit extends that to
> guaranteeing a certain amounts and types of data can be written before
> it knows what the data is, so write messages within that window are
> sufficient for global commits.  Guarantees can be acquired
> asynchronously in advance of need, and can have time and other limits.
> These guarantees are no different in principle from the 1-bit
> guarantee offered by the "can you commit" phase of other commit
> protocols, so they aren't as weak as they seem.

If I understood that, client has to connect to all servers and send data
there, so that after single reply things got committed. That is
definitely not the issue, when there are lots of servers.

That can be the case if client connects to some gate server, which in
turn broadcasts data further, that is how I plan to implement things at
first.

Another approach, which seems also intersting is leader election (per
client), so that leader would broadcast all the data.

-- 
	Evgeniy Polyakov
