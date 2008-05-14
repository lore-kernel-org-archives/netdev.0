From: Sage Weil <sage@newdream.net>
Subject: Re: POHMELFS high performance network filesystem. Transactions,
 failover, performance.
Date: Wed, 14 May 2008 06:35:19 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org>
 <20080513205114.GA16489@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080513205114.GA16489@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > What is your opinion of the Paxos algorithm?
> 
> It is slow. But it does solve failure cases.

For writes, Paxos is actually more or less optimal (in the non-failure 
cases, at least).  Reads are trickier, but there are ways to keep that 
fast as well.  FWIW, Ceph extends basic Paxos with a leasing mechanism to 
keep reads fast, consistent, and distributed.  It's only used for cluster 
state, though, not file data.

I think the larger issue with Paxos is that I've yet to meet anyone who 
wants their data replicated 3 ways (this despite newfangled 1TB+ disks not 
having enough bandwidth to actualy _use_ the data they store).  
Similarly, if only 1 out of 3 replicas is surviving, most people want to 
be able to read their data, while Paxos demands a majority to ensure it is 
correct.  (This is why Paxos is typically used only for critical cluster 
configuration/state, not regular data.)

sage
