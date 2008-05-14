From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 17:52:00 +0400
Message-ID: <20080514135156.GA23131@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sage.

On Wed, May 14, 2008 at 06:35:19AM -0700, Sage Weil (sage@newdream.net) wrote:
> > > What is your opinion of the Paxos algorithm?
> > 
> > It is slow. But it does solve failure cases.
> 
> For writes, Paxos is actually more or less optimal (in the non-failure 
> cases, at least).  Reads are trickier, but there are ways to keep that 
> fast as well.  FWIW, Ceph extends basic Paxos with a leasing mechanism to 
> keep reads fast, consistent, and distributed.  It's only used for cluster 
> state, though, not file data.

Well, it depends... If we are talking about single node perfromance,
then any protocol, which requries to wait for authorization (or any
approach, which waits for acknowledge just after data was sent) is slow.

If we are talking about agregate parallel perfromance, then its basic
protocol with 2 messages is (probably) optimal, but still I'm not
convinced, that 2 messages case is a good choise, I want one :)

> I think the larger issue with Paxos is that I've yet to meet anyone who 
> wants their data replicated 3 ways (this despite newfangled 1TB+ disks not 
> having enough bandwidth to actualy _use_ the data they store).  
> Similarly, if only 1 out of 3 replicas is surviving, most people want to 
> be able to read their data, while Paxos demands a majority to ensure it is 
> correct.  (This is why Paxos is typically used only for critical cluster 
> configuration/state, not regular data.)

I.e. having more than single node to be failed? Google uses 3-way
replication, but I can not see any factor, which will force people from
lowering failure recovering expectations.

-- 
	Evgeniy Polyakov
