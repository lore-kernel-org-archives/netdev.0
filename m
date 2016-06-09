From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] nfnetlink_queue: enable PID info retrieval
Date: Thu, 9 Jun 2016 23:35:17 +0200
Message-ID: <20160609213517.GA25288@breakpoint.cc>
References: <1465505409-1232-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Andre Melkoumian <andre@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34541 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752576AbcFIVfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 17:35:23 -0400
Content-Disposition: inline
In-Reply-To: <1465505409-1232-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Saeed Mahameed <saeedm@mellanox.com> wrote:
> index a1bd161..67de200 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -382,6 +382,7 @@ struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname)
>  	}
>  
>  	sock->file = file;
> +	file->f_owner.sock_pid  = find_get_pid(task_pid_nr(current));
>  	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
>  	file->private_data = sock;
>  	return file;

This looks like this leaks sock_pid reference...?

(find_get_pid -> get_pid -> atomic_inc() , I don't see a put_pid in the
 patch)

Can't comment further than this since I'm not familiar with vfs; e.g.
I can't say if fown_struct is right place or not, or if this approach
even works when creating process has exited after fork, etc.
