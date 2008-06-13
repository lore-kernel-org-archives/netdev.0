From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/3] POHMELFS high performance network filesystem. First steps in parallel processing.
Date: Fri, 13 Jun 2008 20:37:00 +0400
Message-ID: <20080613163700.GA25860@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I'm pleased to announce POHMEL high performance network parallel
distributed filesystem.
POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.

Development status can be tracked in filesystem section [1].

This is a high performance network filesystem with local coherent cache of data
and metadata. Its main goal is distributed parallel processing of data.

This release brings following features:
 * Read requests (data read, directory listing, lookup requests) balancing
 	between multiple servers.
 * Write requests are sent to multiple servers and completed only
 	when all of them sent an ack.
 * Ability to add and/or remove servers from working set at run-time from
	 userspace (via netlink, so the same command can be processed from
	 real network though, but since server does not support it yet,
	 I dropped network part).
 * Documentation (overall view and protocol commands)!
 * Rename command (oops, forgot it in previous releases :)
 * Several new mount options to control client behaviour instead of
	hardcoded numbers.
 * Bug fixes.

Very likely it is one of the last non-bug-fixing release of the kernel
client side, next release will incorporate features, needed for distributed
parallel data processing (like ability to add new servers via network
command from another servers), so most of the work will be devoted to server
code.


Basic POHMELFS features:
 * Local coherent (notes [2]) cache for data and metadata).
 * Completely async processing of all events (hard and symlinks are the only 
    	exceptions) including object creation and data reading/writing.
 * Flexible object architecture optimized for network processing. Ability to
    	create long pathes to object and remove arbitrary huge directoris in 
	single network command.
 * High performance is one of the main design goals.
 * Very fast and scalable multithreaded userspace server. Being in userspace
    	it works with any underlying filesystem and still is much faster than
	async ni-kernel NFS one.
 * Client is able to switch between different servers (if one goes down,
	client automatically reconnects to second and so on).
 * Transactions support. Full failover for all operations. Resending
	transactions to different servers on timeout or error.

Roadmap includes:
 * Server redundancy extensions (ability to store data in multiple locations
	according to regexp rules, like '*.txt' in /root1 and '*.jpg' in /root1
	and /root2.
 * Strong authentification and possible data encryption in network
	channel.
 * Async writing of the data from receiving kernel thread into userspace
	pages via copy_to_user() (check development tracking blog for results).
 * Client dynamical server reconfiguration: ability to add/remove servers
	from working set by server command (as part of development distributed
	server facilities).
 * Start development of the generic parallel distributed server.

One can grab sources from archive or git [2] or check homepage [3].

Thank you.

1. POHMELFS development status.
http://tservice.net.ru/~s0mbre/blog/devel/fs/index.html

2. Source archive.
http://tservice.net.ru/~s0mbre/archive/pohmelfs/
Git tree.
http://tservice.net.ru/~s0mbre/archive/pohmelfs/pohmelfs.git/

3. POHMELFS homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=pohmelfs

4. POHMELFS vs NFS benchmark [iozone results are coming].
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_04_18.html
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_04_14.html
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_05_12.html

5. Cache-coherency notes.
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_05_17.html

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

-- 
	Evgeniy Polyakov
