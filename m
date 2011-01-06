From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove the duplicate #ifdef __KERNEL__
Date: Thu, 06 Jan 2011 11:42:13 -0800 (PST)
Message-ID: <20110106.114213.229742655.davem@davemloft.net>
References: <1294300788-3540-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, ebiederm@xmission.com,
	sjur.brandeland@stericsson.com, xemul@openvz.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294300788-3540-1-git-send-email-xiaosuo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu,  6 Jan 2011 15:59:48 +0800

> Since we are already in #ifdef __KERNEL__, we don't need to check it
> again.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, but please CC: netdev on all networking patches.

> ---
>  include/linux/socket.h |    8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 86b652f..5f65f14 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -30,12 +30,10 @@ struct cred;
>  #define __sockaddr_check_size(size)	\
>  	BUILD_BUG_ON(((size) > sizeof(struct __kernel_sockaddr_storage)))
>  
> -#ifdef __KERNEL__
> -# ifdef CONFIG_PROC_FS
> +#ifdef CONFIG_PROC_FS
>  struct seq_file;
>  extern void socket_seq_show(struct seq_file *seq);
> -# endif
> -#endif /* __KERNEL__ */
> +#endif
>  
>  typedef unsigned short	sa_family_t;
>  
> @@ -311,7 +309,6 @@ struct ucred {
>  /* IPX options */
>  #define IPX_TYPE	1
>  
> -#ifdef __KERNEL__
>  extern void cred_to_ucred(struct pid *pid, const struct cred *cred, struct ucred *ucred);
>  
>  extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
> @@ -333,6 +330,5 @@ struct timespec;
>  
>  extern int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
>  			  unsigned int flags, struct timespec *timeout);
> -#endif
>  #endif /* not kernel and not glibc */
>  #endif /* _LINUX_SOCKET_H */
