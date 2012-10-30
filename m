From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] net: fix compile warning in af_unix.c
Date: Tue, 30 Oct 2012 07:00:40 -0700
Message-ID: <20121030070040.5bdf0f0a@nehalam.linuxnetplumber.net>
References: <1351581396-20493-1-git-send-email-windsdaemon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org
To: Jing Wang <windsdaemon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48856 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792Ab2J3OBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 10:01:32 -0400
In-Reply-To: <1351581396-20493-1-git-send-email-windsdaemon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Oct 2012 15:16:36 +0800
Jing Wang <windsdaemon@gmail.com> wrote:

> This patch fix some compile warning as follows:
> net/unix/af_unix.c: In function 'unix_bind':
> net/unix/af_unix.c:895: warning: 'path.dentry' may be used uninitialized in this function
> net/unix/af_unix.c:895: warning: 'path.mnt' may be used uninitialized in this function
> 
> Signed-off-by: Jing Wang <windsdaemon@gmail.com>
> ---
>  net/unix/af_unix.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 5b5c876..9f710ac 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -895,6 +895,8 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  		struct path path;
>  		umode_t mode = S_IFSOCK |
>  		       (SOCK_INODE(sock)->i_mode & ~current_umask());
> +		path.mnt = NULL;
> +		path.dentry = NULL;
>  		err = unix_mknod(sun_path, mode, &path);
>  		if (err) {
>  			if (err == -EEXIST)

I appreciate the effort to silence warnings. But this warning is a false
positive that only occurs on some versions of Gcc. With gcc 4.7 the
warning does not occur.

The general consensus has been NOT to do initializations or other changes
if the problem is due to Gcc bug.
