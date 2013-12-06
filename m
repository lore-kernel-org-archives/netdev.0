From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] unix: fix build warning of used uninitialized variable
Date: Thu, 05 Dec 2013 22:24:39 -0800
Message-ID: <1386311079.30495.236.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52A16924.9050407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	ebiederm@xmission.com, gaofeng@cn.fujitsu.com,
	jacob.e.keller@intel.com, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:38625 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061Ab3LFGYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:24:41 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so484125pbb.31
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 22:24:40 -0800 (PST)
In-Reply-To: <52A16924.9050407@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-06 at 14:05 +0800, Wang Weidong wrote:
> af_unix.c: In function unix_bind
> af_unix.c:893: warning: path may be used uninitialized in this function
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/unix/af_unix.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 01625cc..4155ed3 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -893,6 +893,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  		struct path path;
>  		umode_t mode = S_IFSOCK |
>  		       (SOCK_INODE(sock)->i_mode & ~current_umask());
> +		memset(&path, 0, sizeof(path));
>  		err = unix_mknod(sun_path, mode, &path);
>  		if (err) {
>  			if (err == -EEXIST)

You should update your compiler, this patch is not needed.
