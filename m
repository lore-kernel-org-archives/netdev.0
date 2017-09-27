From: Lee Duncan <lduncan@suse.com>
Subject: Re: [PATCH 2/2] uapi: add a compatibility layer between linux/uio.h and glibc
Date: Wed, 27 Sep 2017 09:46:02 -0700
Message-ID: <20170927164602.2914-1-lduncan@suse.com>
References: <20170221201914.GA28360@altlinux.org>
Cc: "Dmitry V. Levin" <ldv@altlinux.org>,
        "David Miller" <davem@davemloft.net>, Lee Duncan <lduncan@suse.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20170221201914.GA28360@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ping? I never saw any response to this.

On Wed, 22 Feb 2017 05:29:47 +0300, Dmitry V Levin wrote:
> Do not define struct iovec in linux/uio.h when <sys/uio.h> or <fcntl.h>
> is already included and provides these definitions.
> 
> This fixes the following compilation error when <sys/uio.h> or <fcntl.h>
> is included before <linux/uio.h>:
> 
> /usr/include/linux/uio.h:16:8: error: redefinition of 'struct iovec'
> 
> Signed-off-by: Dmitry V. Levin <ldv@...linux.org>
> ---
>  include/uapi/linux/libc-compat.h | 10 ++++++++++
>  include/uapi/linux/uio.h         |  3 +++
>  2 files changed, 13 insertions(+)
> 
> diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
> index 481e3b1..9b88586 100644
> --- a/include/uapi/linux/libc-compat.h
> +++ b/include/uapi/linux/libc-compat.h
> @@ -205,6 +205,13 @@
>  #define __UAPI_DEF_TIMEZONE		1
>  #endif
>  
> +/* Coordinate with glibc bits/uio.h header. */
> +#if defined(_SYS_UIO_H) || defined(_FCNTL_H)
> +#define __UAPI_DEF_IOVEC		0
> +#else
> +#define __UAPI_DEF_IOVEC		1
> +#endif
> +
>  /* Definitions for xattr.h */
>  #if defined(_SYS_XATTR_H)
>  #define __UAPI_DEF_XATTR		0
> @@ -261,6 +268,9 @@
>  #define __UAPI_DEF_TIMEVAL			1
>  #define __UAPI_DEF_TIMEZONE			1
>  
> +/* Definitions for uio.h */
> +#define __UAPI_DEF_IOVEC		1
> +
>  /* Definitions for xattr.h */
>  #define __UAPI_DEF_XATTR		1
>  
> diff --git a/include/uapi/linux/uio.h b/include/uapi/linux/uio.h
> index 2731d56..e6e12cf 100644
> --- a/include/uapi/linux/uio.h
> +++ b/include/uapi/linux/uio.h
> @@ -9,15 +9,18 @@
>  #ifndef _UAPI__LINUX_UIO_H
>  #define _UAPI__LINUX_UIO_H
>  
> +#include <linux/libc-compat.h>
>  #include <linux/compiler.h>
>  #include <linux/types.h>
>  
>  
> +#if __UAPI_DEF_IOVEC
>  struct iovec
>  {
>  	void __user *iov_base;	/* BSD uses caddr_t (1003.1g requires void *) */
>  	__kernel_size_t iov_len; /* Must be size_t (1003.1g) */
>  };
> +#endif /* __UAPI_DEF_IOVEC */
>  
>  /*
>   *	UIO_MAXIOV shall be at least 16 1003.1g (5.4.1.1)
> -- 
> ldv

-- 
Lee Duncan
SUSE Labs
