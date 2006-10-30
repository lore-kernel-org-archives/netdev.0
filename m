From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Any strong reason why socket dentries are hashed in
 global d_hash table ?
Date: Mon, 30 Oct 2006 14:15:27 -0800 (PST)
Message-ID: <20061030.141527.74717587.davem@davemloft.net>
References: <20061029132440.4bb93676.randy.dunlap@oracle.com>
	<20061029.160402.92581862.davem@davemloft.net>
	<45466EFF.5060108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56786
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422690AbWJ3WPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 17:15:32 -0500
To: dada1@cosmosbay.com
In-Reply-To: <45466EFF.5060108@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 30 Oct 2006 22:30:39 +0100

> In sock_attach_fd(), we are currently using
> 
> d_add(file->f_dentry, SOCK_INODE(sock));
> 
> This has the effect to insert the dentry into the dentry_hashtable.
> 
> I was wondering if it is really necessary : On a machine with many sockets, 
> the dentry_hashtable lookups may be slowed down for no good reason. (sockets 
> are not accessable by other means than socket() syscall, and not subject to 
> 'unuse and LRU freeable syndrom').
> 
> If we replace d_add(file->f_dentry, SOCK_INODE(sock)) call by
> d_instantiate(file->f_dentry, SOCK_INODE(sock)), we also avoid using rcu 
> callback when socket is closed. (We would have to not provide a d_op->d_delete 
> () method in sockfs_dentry_operations)

Sounds like a useful optimization for sure.

You can't mount sockfs on the filesystem, but they are visible
via /proc/${pid}/fd/, I wonder if the dentry hashing is required
just to make those nodes visible properly?
