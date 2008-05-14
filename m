From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Thu, 15 May 2008 01:19:19 +0400
Message-ID: <20080514211919.GA13513@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <482B3899.9070008@garzik.org> <20080514193234.GA10165@2ka.mipt.ru> <482B4D80.5080808@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, Sage Weil <sage@newdream.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <482B4D80.5080808@garzik.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2008 at 04:37:20PM -0400, Jeff Garzik (jeff@garzik.org) wrote:
> That said, the biggest distributed systems seem to inevitably grow their 
> own "front end server" layer.  Clients connect to N caching/application 
> servers, each of which behaves as you describe:  the caching/app server 
> connects to the control and data networks, and performs the necessary 
> load/store operations.
> 
> Personally, I think the most simple thing for _users_ is where 
> semi-smart clients open multiple connections to an amorphous cloud of 
> servers, where the cloud is self-optimizing, self-balancing, and 
> self-repairing internally.

Well, that's how things exist today - POHMELFS client connects to number
of servers and can send data to all of them (currently it doest that for
only 'active' server, i.e. that which was not failed, but that can be
trivially changed). It should be extended to receive 'add/remove server
to the group' command and liekly that's all (modulo other todo items
which are not yet resolved). Then that group becomes quorum and client
has to get response from them. Kind of that...

What I do not like, is putting lots of logic into client, like following
inner server state changes (sync/not sync, quorum election and so on).
With above dumb scheme it should not, but some other magic in the server
land will tell client with whom to start working.


-- 
	Evgeniy Polyakov
