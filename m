From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [0/5] New POHMELFS release.
Date: Tue, 18 Nov 2008 22:33:45 +0300
Message-ID: <12270368303809-git-send-email-zbr@ioremap.net>
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

This is a new release of the POHMEL filesystem.
POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.

This is a high performance network filesystem with local coherent cache of data
and metadata. Its main goal is distributed parallel processing of data.
Network filesystem is a client transport.

POHMELFS protocol was proven to be superior to NFS in lots
(if not all, then it is in a roadmap) operations.

Basic POHMELFS features:

    * Local coherent cache for data and metadata. (Byte-range) locking. Locks were 
    	prepared to be byte-range, but since all Linux filesystems lock the whole
	inode, it was decided to lock the whole object during writing. Actual messages
	are being sent for locking/cache coherency protocol are byte-range, but because
	the whole inode is locked, lock is cached, so range actually is equal to the
	inode size. One can simultaneously write into the same page via different offsets
	from different client, and every time file will be coherent on all clients which
	do it and on the server itself.
    * Completely async processing of all events (hard and symlinks are the only exceptions)
    	including object creation and data reading and writing.
    * Flexible object architecture optimized for network processing. Ability to create long
    	pathes to object and remove arbitrary huge directories in single network command.
    * High performance is one of the main design goals.
    * Very fast and scalable multithreaded userspace server. Being in userspace it works
    	with any underlying filesystem and still is much faster than async in-kernel NFS one.
    * Transactions support. Full failover for all operations. Resending transactions to
    	different servers on timeout or error.
    * Client is able to switch between different servers
    	(if one goes down, client automatically reconnects to second and so on).
    * Client parallel extensions: ability to write to multiple servers and
    	balance reading between them.
    * Client dynamic server reconfiguration: ability to add/remove servers from
    	working set in run-time.
    * Strong authentification and possible data encryption in network channel.
    * Extended attributes support.

This release brings following features:

    * combine locking with inode attribute changes
    * add get/set attrbibute commands into cache coherency protocol
    	(attributes are cached and flushed to the server at a writeback time or
	on demand because of cache coherency protocol)
    * crypto threads pool's cleanup
    * 2.6.27 rebase
    * optimize read/write locking and number of messages
    	needed for cache coherency management
    * debug cleanups
    * bug fixes

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

1. POHMELFS homepage
http://www.ioremap.net/projects/pohmelfs

2. GIT trees.
http://www.ioremap.net/cgi-bin/gitweb.cgi
