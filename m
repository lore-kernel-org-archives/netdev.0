From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH] kernel: audit: beautify code, for extern function,
 better to check its parameters by itself
Date: Wed, 10 Apr 2013 13:31:03 -0400 (EDT)
Message-ID: <1216477171.11118824.1365615063121.JavaMail.root@redhat.com>
References: <5161347B.8090604@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5161347B.8090604@asianux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> 
>   __audit_socketcall is an extern function.
>   better to check its parameters by itself.
> 
>     also can return error code, when fail (find invalid parameters).
>     also use macro instead of real hard code number
>     also give related comments for it.
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  include/linux/audit.h |   12 ++++++++----
>  kernel/auditsc.c      |    9 ++++++---
>  net/socket.c          |    6 ++++--
>  3 files changed, 18 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/audit.h b/include/linux/audit.h

> @@ -354,7 +358,7 @@ static inline int audit_bprm(struct linux_binprm *bprm)
>  {
>  	return 0;
>  }
> -static inline void audit_socketcall(int nargs, unsigned long *args)
> +static inline int audit_socketcall(int nargs, unsigned long *args)
>  { }
>  static inline void audit_fd_pair(int fd1, int fd2)
>  { }

This now returns a value but you forgot to return a value.  Thus this would not even build...   I fixed it up myself.

-Eric
