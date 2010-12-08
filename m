From: Martin Sustrik <sustrik@250bpm.com>
Subject: Polling on sockets in kernel space and struct file
Date: Wed, 08 Dec 2010 15:33:59 +0100
Message-ID: <4CFF9757.3070100@250bpm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin Lucina <mato@kotelna.sk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:46491 "EHLO mail.moloch.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755046Ab0LHOll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 09:41:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

As part of implementing a new experimental protocol family, we are 
trying to create a socket in kernel. This seems to be easy, just use 
sock_create_kern(). However, the socket returned by this function does 
not have associated file structure; thus it cannot be polled on using 
poll_initwait() and friends.

We have tried to create the appropriate struct file using sock_map_fd(), 
but this has two problems:

1) We do not want our internal socket to be visible in the process 
context, i.e. it should not have a file descriptor.

2) During process exit, we get a kernel BUG from iput() in fs/inode.c:1260.

We then tried another approach using anon_inode_getfile() to get a 
struct file, but this still produces the problem 2) above.

Any help/advice on how to proceed would be appreciated; for reference 
our work in progress can be seen at

http://github.com/sustrik/linux-2.6/blob/sp-v2.6.36/net/sp/af_sp.c

Thanks,

Martin
