From: Damian Hobson-Garcia <dhobsong@igel.co.jp>
Subject: Re: [PATCH v3 1/1] eventfd: implementation of EFD_MASK flag
Date: Thu, 22 Oct 2015 16:47:03 +0900
Message-ID: <56289477.6090007@igel.co.jp>
References: <1444873328-8466-1-git-send-email-dhobsong@igel.co.jp>
 <1444873328-8466-2-git-send-email-dhobsong@igel.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	David.Laight@aculab.com
To: viro@zeniv.linux.org.uk, sustrik@250bpm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36163 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755346AbbJVHrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 03:47:09 -0400
Received: by pacfv9 with SMTP id fv9so83515950pac.3
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 00:47:08 -0700 (PDT)
In-Reply-To: <1444873328-8466-2-git-send-email-dhobsong@igel.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

> diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
> index ff0b981..87de343 100644
> --- a/include/linux/eventfd.h
> +++ b/include/linux/eventfd.h
<snip>
>  
> -/*
> - * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
> - * new flags, since they might collide with O_* ones. We want
> - * to re-use O_* flags that couldn't possibly have a meaning
> - * from eventfd, in order to leave a free define-space for
> - * shared O_* flags.
> - */
> -#define EFD_SEMAPHORE (1 << 0)
> -#define EFD_CLOEXEC O_CLOEXEC
> -#define EFD_NONBLOCK O_NONBLOCK
> -
> -#define EFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
> -#define EFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS | EFD_SEMAPHORE)
> -
>  struct file;
>  
>  #ifdef CONFIG_EVENTFD
> diff --git a/include/uapi/linux/eventfd.h b/include/uapi/linux/eventfd.h
> new file mode 100644
> index 0000000..097dcad
> --- /dev/null
> +++ b/include/uapi/linux/eventfd.h
> @@ -0,0 +1,33 @@
<snip>
> +
> +/*
> + * CAREFUL: Check include/asm-generic/fcntl.h when defining
> + * new flags, since they might collide with O_* ones. We want
> + * to re-use O_* flags that couldn't possibly have a meaning
> + * from eventfd, in order to leave a free define-space for
> + * shared O_* flags.
> + */
> +
> +/* Provide semaphore-like semantics for reads from the eventfd. */
> +#define EFD_SEMAPHORE (1 << 0)
> +/* Provide event mask semantics for the eventfd. */
> +#define EFD_MASK (1 << 1)
> +/*  Set the close-on-exec (FD_CLOEXEC) flag on the eventfd. */
> +#define EFD_CLOEXEC O_CLOEXEC
> +/*  Create the eventfd in non-blocking mode. */
> +#define EFD_NONBLOCK O_NONBLOCK
> +#endif /* _UAPI_LINUX_EVENTFD_H */
> 

Since the latest version of this patch adds only the EFD_MASK definition
to the eventfd header, I was wondering if it was really
necessary/recommended to move the definitions from linux/eventfd.h to
linux/uapi/eventfd.h.  From my understanding, the EFD_SEMAPHORE (and now
EFD_MASK) define(s) are provided to user space from the libc headers
only. Any advice would be greatly appreciated.

Thank you,
Damian
