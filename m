From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/3] POHMELFS high performance network filesystem. IPv6 support, documentation update.
Date: Fri, 25 Jul 2008 23:01:34 +0400
Message-ID: <20080725190134.GA30685@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I'm pleased to announce POHMEL high performance network parallel distributed filesystem.
POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.

Development status can be tracked in filesystem section [1].

This is a high performance network filesystem with local coherent cache of data
and metadata. Its main goal is distributed parallel processing of data.
System supports strong transaction model with failover recovery, allows to 
encrypt/hash whole data channel and perform read load balancing and
write to multiple servers in parallel.

This release was fully made by external developers.
Great thanks to Adam Langley <agl@imperialviolet.org> for his documentation
update and Varun Chandramohan <varunc@linux.vnet.ibm.com> for the server
IPv6 support.

Currenyly work is being concentrated on the distributed facilities of
the POHMELFS [6].

Short changelog:
 * Documentation update by Adam Langley <agl@imperialviolet.org>, short
	notes after talk with Pavel Machek.
 * server and configuration utility IPv6 support (kernel part works
	without changes)

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
 * Strong encryption and/or hashing of the data channel with
 	autoconfiguration of the server/client supported crypto algorithms.

Roadmap includes:
 * Server redundancy extensions (ability to store data in multiple locations
	according to regexp rules, like '*.txt' in /root1 and '*.jpg' in /root1
	and /root2.
 * Async writing of the data from receiving kernel thread into userspace
	pages via copy_to_user() (check development tracking blog for results).
 * Client dynamical server reconfiguration: ability to add/remove servers
	from working set by server command (as part of development distributed
	server facilities).
 * Generic parallel distributed server algorithms.

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
Plain async NFS vs sha1+cbc(aes) POHMELFS
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_07_07.html
Plain filesystems.
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_06_25.html

5. Cache-coherency notes.
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_05_17.html

6. Distributed POHMELFS design notes.
http://tservice.net.ru/~s0mbre/blog/devel/fs/2008_07_22.html

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

-- 
	Evgeniy Polyakov
