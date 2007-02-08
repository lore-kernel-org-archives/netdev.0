From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : cleanup sock_from_file()
Date: Thu, 08 Feb 2007 15:00:09 -0800 (PST)
Message-ID: <20070208.150009.92582755.davem@davemloft.net>
References: <20070202120528.GA10392@de.ibm.com>
	<20070206.144106.39659974.davem@davemloft.net>
	<45C9093D.1030605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1945936AbXBHXAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 18:00:10 -0500
In-Reply-To: <45C9093D.1030605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 07 Feb 2007 00:03:25 +0100

> I believe dead code from sock_from_file() can be cleaned up.
> 
> All sockets are now built using sock_attach_fd(), that puts the 'sock' pointer 
> into file->private_data and &socket_file_ops into file->f_op
> 
> I could not find a place where file->private_data could be set to NULL, 
> keeping opened the file.
> 
> So to get 'sock' from a 'file' pointer, either :
> 
> - This is a socket file (f_op == &socket_file_ops), and we can directly get 
> 'sock' from private_data.
> - This is not a socket, we return -ENOTSOCK and dont even try to find a socket 
> via dentry/inode :)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Looks good to me, applied, thanks Eric.
