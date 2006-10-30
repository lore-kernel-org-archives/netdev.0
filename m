From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC] Any strong reason why socket dentries are hashed in global
 d_hash table ?
Date: Mon, 30 Oct 2006 22:30:39 +0100
Message-ID: <45466EFF.5060108@cosmosbay.com>
References: <20061029132440.4bb93676.randy.dunlap@oracle.com>
 <20061029.160402.92581862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:5069 "EHLO smTp.neuf.fr")
	by vger.kernel.org with ESMTP id S1161396AbWJ3VeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 16:34:24 -0500
Received: from [192.168.30.203] ([84.7.15.81]) by sp604003mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7Y005RVX32U9W0@sp604003mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Mon, 30 Oct 2006 22:30:40 +0100 (CET)
In-reply-to: <20061029.160402.92581862.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In sock_attach_fd(), we are currently using

d_add(file->f_dentry, SOCK_INODE(sock));

This has the effect to insert the dentry into the dentry_hashtable.

I was wondering if it is really necessary : On a machine with many sockets, 
the dentry_hashtable lookups may be slowed down for no good reason. (sockets 
are not accessable by other means than socket() syscall, and not subject to 
'unuse and LRU freeable syndrom').

If we replace d_add(file->f_dentry, SOCK_INODE(sock)) call by
d_instantiate(file->f_dentry, SOCK_INODE(sock)), we also avoid using rcu 
callback when socket is closed. (We would have to not provide a d_op->d_delete 
() method in sockfs_dentry_operations)

Maybe I just provide a patch instead of just talking ? :)

Eric
