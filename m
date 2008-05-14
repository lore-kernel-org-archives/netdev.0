From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 23:32:35 +0400
Message-ID: <20080514193234.GA10165@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <482B3899.9070008@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, Sage Weil <sage@newdream.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <482B3899.9070008@garzik.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2008 at 03:08:09PM -0400, Jeff Garzik (jeff@garzik.org) wrote:
> Evgeniy Polyakov wrote:
> >That can be the case if client connects to some gate server, which in
> >turn broadcasts data further, that is how I plan to implement things at
> >first.
> 
> That means you are less optimal than the direct-to-storage-server path 
> in NFSv4.1, then........

No, server to connect is the server, which stores data. By addition it
will also store it to some other places according to distributed
algorithm (like weaver, raid, mirror, whatever).

> <waves red flag in front of the bull>
> 
> If access controls permit, the ideal would be for the client to avoid an 
> intermediary when storing data.  The client only _needs_ a consensus 
> reply that their transaction was committed.  They don't necessarily need 
> an intermediary to do the boring data transfer work.

Sure the less number of machines between client and storage we have, the
faster and more robust we are.

Either client has to write data to all servers, or it has to write it to
one and wait utill that server will broadcast it further (to quorum or any
number of machines it wants). Having pure client to think to what
servers it has to put its data is a bit wrong (if not saying more),
since it has to join not only data network, but also control one, to
check that some servers are alive or not, to be able not to race, when
server is recovering and so on...

-- 
	Evgeniy Polyakov
