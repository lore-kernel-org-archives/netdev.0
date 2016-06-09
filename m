From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] nfnetlink_queue: enable PID info retrieval
Date: Thu, 09 Jun 2016 14:17:11 -0700
Message-ID: <1465507031.7945.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465505409-1232-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
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
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34155 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbcFIVRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 17:17:14 -0400
In-Reply-To: <1465505409-1232-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-09 at 23:50 +0300, Saeed Mahameed wrote:
> From: Matthew Finlay <matt@mellanox.com>


> diff --git a/net/socket.c b/net/socket.c
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

Wow, that is a serious memory leak weapon (of struct pid)

Why don't you store the pid value, instead of a pointer ?
