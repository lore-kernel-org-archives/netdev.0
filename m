From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Thu, 15 May 2008 02:02:52 +0400
Message-ID: <20080514220252.GA14378@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <20080514213251.GB23758@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sage Weil <sage@newdream.net>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514213251.GB23758@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2008 at 10:32:51PM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> Look up Bittorrent, and bandwidth diffusion generally.  Also look up
> multicast trees.
> 
> Sometimes it's faster for a client to send to many servers; sometimes
> it's faster to send fewer and have them relayed by intermediaries -
> because every packet takes time to transmit, and network topologies
> aren't always homogenous or symmetric.
> 
> There is no simple answer which is optimal for all networks.

Yep, having multiple connections is worse for high-performance networks
and is a great win for long latency links. If client to server
connection is slower than server-server one, than having single gate
server, which broadcasts data to others is a win over multiple
connection to different servers. But if communication is roughly the
same over all links, than... I think I agree that client-to-many is a
better approach, since perormance of client-to-many will be the same as
client-to-gate-to-others (since link is the same everywhere), but if
gate server fails, reconnection and other management tasks introduce
huge latency here (new gate server, new connection and so on), while
with client-to-many we just proceed with other connections.

> > Another approach, which seems also intersting is leader election (per
> > client), so that leader would broadcast all the data.
> 
> Leader election is part of standard Paxos too :-)

But that's a different leader :)

> If you have a single data forwarder elected per client, then if one
> client generates a lot of traffic, you concentrate a lot of traffic to
> one network link and one CPU.  Sometimes it's better to elect several
> leaders per client, and hash requests onto them.  You diffuse CPU and
> traffic, but reduce opportunities to aggregate transactions into fewer
> message.  It's an interesting problem, again probably with different
> optimal results for different networks.

Probably idea I described in other mail to Jeff, when client just
connects to number of servers and can process command of adding/dropping
server from that group, and balances reading between them and sends
writes/metadata update to all of them, and all logic behind that group
selection is hidded in the servers cloud, is the best choice...

-- 
	Evgeniy Polyakov
