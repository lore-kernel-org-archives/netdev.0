From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 23:28:37 +0100
Message-ID: <20080514222837.GF23758@shareable.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <20080514213251.GB23758@shareable.org> <20080514220252.GA14378@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sage Weil <sage@newdream.net>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514220252.GA14378@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> > Look up Bittorrent, and bandwidth diffusion generally.  Also look up
> > multicast trees.
> > 
> > Sometimes it's faster for a client to send to many servers; sometimes
> > it's faster to send fewer and have them relayed by intermediaries -
> > because every packet takes time to transmit, and network topologies
> > aren't always homogenous or symmetric.
> > 
> > There is no simple answer which is optimal for all networks.
> 
> Yep, having multiple connections is worse for high-performance networks
> and is a great win for long latency links.

Not just long latency.  If you have a low latency link which is very
busy, perhaps a client doing lots of requests, or doing other things,
that pushes up the _effective_ latency.

> > If you have a single data forwarder elected per client, then if one
> > client generates a lot of traffic, you concentrate a lot of traffic to
> > one network link and one CPU.  Sometimes it's better to elect several
> > leaders per client, and hash requests onto them.  You diffuse CPU and
> > traffic, but reduce opportunities to aggregate transactions into fewer
> > message.  It's an interesting problem, again probably with different
> > optimal results for different networks.
> 
> Probably idea I described in other mail to Jeff, when client just
> connects to number of servers and can process command of adding/dropping
> server from that group, and balances reading between them and sends
> writes/metadata update to all of them, and all logic behind that group
> selection is hidded in the servers cloud, is the best choice...

I think that's a fine choice, but it doesn't solve difficult
problems.  You still have to implement the server cloud. :-)

It's possible that implementing server cloud protocol _and_ simple
client protocol may be more work than just server cloud protocol.  I'm
not sure.  Thoughts welcome.

-- Jamie
