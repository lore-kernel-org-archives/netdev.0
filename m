From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/1] af_unix.c: fix the compile warning in unix_bind
Date: Sat, 27 Oct 2012 22:54:26 -0700
Message-ID: <87390z87l9.fsf@xmission.com>
References: <1351219727-6085-1-git-send-email-windsdaemon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org
To: Jing Wang <windsdaemon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57991 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab2J1Fyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 01:54:35 -0400
In-Reply-To: <1351219727-6085-1-git-send-email-windsdaemon@gmail.com> (Jing
	Wang's message of "Fri, 26 Oct 2012 10:48:47 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jing Wang <windsdaemon@gmail.com> writes:

> Signed-off-by: Jing Wang <windsdaemon@gmail.com>
> ---
>  net/unix/af_unix.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 5b5c876..3f7d9d5 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -860,6 +860,8 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  	unsigned int hash;
>  	struct unix_address *addr;
>  	struct hlist_head *list;
> +	struct path path;
> +	umode_t mode;

This code motion to the top level in the function is also wrong.

>  	err = -EINVAL;
>  	if (sunaddr->sun_family != AF_UNIX)
> @@ -890,11 +892,12 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  	addr->len = addr_len;
>  	addr->hash = hash ^ sk->sk_type;
>  	atomic_set(&addr->refcnt, 1);
> -
> +
>  	if (sun_path[0]) {
> -		struct path path;
> -		umode_t mode = S_IFSOCK |
> +		mode = S_IFSOCK |
>  		       (SOCK_INODE(sock)->i_mode & ~current_umask());
> +
> +		memset(&path, 0, sizeof(path));
>  		err = unix_mknod(sun_path, mode, &path);
>  		if (err) {
>  			if (err == -EEXIST)

Eric
