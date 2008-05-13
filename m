From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover,
 performance.
Date: Tue, 13 May 2008 15:09:06 -0400
Message-ID: <4829E752.8030104@garzik.org>
References: <20080513174523.GA1677@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38204 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756018AbYEMTJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 15:09:12 -0400
In-Reply-To: <20080513174523.GA1677@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi.
> 
> I'm please to announce POHMEL high performance network filesystem.
> POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.
> 
> Development status can be tracked in filesystem section [1].
> 
> This is a high performance network filesystem with local coherent cache of data
> and metadata. Its main goal is distributed parallel processing of data. Network 
> filesystem is a client transport. POHMELFS protocol was proven to be superior to
> NFS in lots (if not all, then it is in a roadmap) operations.
> 
> This release brings following features:
>  * Fast transactions. System will wrap all writings into transactions, which
>  	will be resent to different (or the same) server in case of failure.
> 	Details in notes [1].
>  * Failover. It is now possible to provide number of servers to be used in
>  	round-robin fasion when one of them dies. System will automatically
> 	reconnect to others and send transactions to them.
>  * Performance. Super fast (close to wire limit) metadata operations over
>  	the network. By courtesy of writeback cache and transactions the whole
> 	kernel archive can be untarred by 2-3 seconds (including sync) over
> 	GigE link (wire limit! Not comparable to NFS).
> 
> Basic POHMELFS features:
>     * Local coherent (notes [5]) cache for data and metadata.
>     * Completely async processing of all events (hard and symlinks are the only 
>     	exceptions) including object creation and data reading.
>     * Flexible object architecture optimized for network processing. Ability to
>     	create long pathes to object and remove arbitrary huge directoris in 
> 	single network command.
>     * High performance is one of the main design goals.
>     * Very fast and scalable multithreaded userspace server. Being in userspace
>     	it works with any underlying filesystem and still is much faster than
> 	async ni-kernel NFS one.
> 
> Roadmap includes:
>     * Server extension to allow storing data on multiple devices (like creating mirroring),
>     	first by saving data in several local directories (think about server, which mounted
> 	remote dirs over POHMELFS or NFS, and local dirs).
>     * Client/server extension to report lookup and readdir requests not only for local
>     	destination, but also to different addresses, so that reading/writing could be
> 	done from different nodes in parallel.
>     * Strong authentification and possible data encryption in network channel.
>     * Async writing of the data from receiving kernel thread into
>     	userspace pages via copy_to_user() (check development tracking
> 	blog for results).
> 
> One can grab sources from archive or git [2] or check homepage [3].
> Benchmark section can be found in the blog [4].
> 
> The nearest roadmap (scheduled or the end of the month) includes:
>  * Full transaction support for all operations (only writeback is
>  	guarded by transactions currently, default network state
> 	just reconnects to the same server).
>  * Data and metadata coherency extensions (in addition to existing
> 	commented object creation/removal messages). (next week)
>  * Server redundancy.

This continues to be a neat and interesting project :)

Where is the best place to look at client<->server protocol?

Are you planning to support the case where the server filesystem dataset 
does not fit entirely on one server?

What is your opinion of the Paxos algorithm?

	Jeff



