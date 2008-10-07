From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/3] The new POHMELFS release.
Date: Wed, 8 Oct 2008 01:19:25 +0400
Message-ID: <20081007211925.GA1274@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I'm pleased to announce the new POHMELFS release.
This is a major change in the Parallel Optimized Host Message Exchange
Layered File System: completely rewritten distributed (byte-range)
locking subsystem. Locks are actually byte-range, but since every Linux
FS locks the whole inode, POHMELFS locks also do this. Multiple writers
are somewhat serialized and thus cache is coherent (pages either contain
valid data or they are not uptodate) on all clients at any time.

Other changes made in this release:
 * Documentation update. Fixed by Adam Langley (agl_imperialviolet.org)
 * Add/del/show commands patch from Varun Chandramohan
	(varunc_linux.vnet.ibm.com)
 * Bug fixes and cleanups.

POHMELFS is a very high performance parallel network filesystem with
local coherent cache of data and metadata. Its main goal is distributed
processing of the data.

Features supported by POHMELFS:
 * Local coherent cache for data and metadata.
 * Completely async processing of all events (hard and symlinks are the
	only exceptions) including object creation and data reading and
	writing.
 * Flexible object architecture optimized for network processing. Ability
	to create long pathes to object and remove arbitrary huge 
	directories in single network command.
 * High performance is one of the main design goals.
 * Very fast and scalable multithreaded userspace server. Being in
	userspace it works with any underlying filesystem and still is much
	faster than async in-kernel NFS one.
 * Transactions support. Full failover for all operations. Resending
	transactions to different servers on timeout or error.
 * Client is able to switch between different servers (if one goes down,
	client automatically reconnects to second and so on).
 * Client parallel extensions: ability to write to multiple servers and
	balance reading between them.
 * Client dynamical server reconfiguration: ability to add/remove servers
	from working set in run-time.
 * Strong authentification and possible data encryption in network channel.

POHMELFS roadmap now includes distributed and parallel facilities of the
server.

1. POHMELFS homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=pohmelfs

2. POHMELFS archive.
http://tservice.net.ru/~s0mbre/archive/pohmelfs/

3. GIT trees.
http://tservice.net.ru/~s0mbre/cgi-bin/gitweb.cgi

4. Development status.
http://tservice.net.ru/~s0mbre/blog//devel/fs

-- 
	Evgeniy Polyakov
