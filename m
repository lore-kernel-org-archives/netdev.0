From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/3] POHMELFS high performance network filesystem. First steps in parallel processing.
Date: Mon, 7 Jul 2008 22:07:36 +0400
Message-ID: <20080707180736.GA15687@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:35758 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756734AbYGGSHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 14:07:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I'm pleased to announce POHMEL high performance network parallel distributed filesystem.
POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.

Development status can be tracked in filesystem section [1].

This is a high performance network filesystem with local coherent cache of data
and metadata. Its main goal is distributed parallel processing of data.
System supports strong transaction model with failover recovery, allows to 
encrypt/hash whole data channel and perform read load balancing and
write to multiple servers in parallel.

This release brings following features:
 * Strong crypto support. One can specify encryption method (like
 	cbc(aes), hash or digest, or all of them to be performed on
	whole data channel (except headers). If special mount option is
	specified, then mount will file if server does not support
	requested by client crypto options. By defalt that crypto
	options will be skipped.
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

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

-- 
	Evgeniy Polyakov
