From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] audit: log 32-bit socketcalls
Date: Mon, 16 Jan 2017 13:27:45 -0500 (EST)
Message-ID: <20170116.132745.1831536278596554491.davem@davemloft.net>
References: <dd937da01da72da9277e44ed79abd1f4618c14c5.1484297765.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-audit@redhat.com, aixer77@gmail.com, eparis@redhat.com,
        pmoore@redhat.com, sgrubb@redhat.com
To: rgb@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dd937da01da72da9277e44ed79abd1f4618c14c5.1484297765.git.rgb@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Guy Briggs <rgb@redhat.com>
Date: Fri, 13 Jan 2017 04:51:48 -0500

> diff --git a/include/linux/audit.h b/include/linux/audit.h
> index 9d4443f..43d8003 100644
> --- a/include/linux/audit.h
> +++ b/include/linux/audit.h
> @@ -387,6 +387,18 @@ static inline int audit_socketcall(int nargs, unsigned long *args)
>  		return __audit_socketcall(nargs, args);
>  	return 0;
>  }
> +static inline int audit_socketcall_compat(int nargs, u32 *args)
> +{

Please put an empty line between function definitions.

> +	if (unlikely(!audit_dummy_context())) {
> +		int i;
> +		unsigned long a[AUDITSC_ARGS];

Please order local variable declarations from longest to shortest line.

> +
> +		for (i=0; i<nargs; i++)

Please put a space around operators such as "=" and "<".

> +			a[i] = (unsigned long)args[i];
> +		return __audit_socketcall(nargs, a);
> +	}
> +	return 0;
> +}
>  static inline int audit_sockaddr(int len, void *addr)

Again, empty line between function definitions please.

> @@ -781,14 +782,24 @@ COMPAT_SYSCALL_DEFINE5(recvmmsg, int, fd, struct compat_mmsghdr __user *, mmsg,
>  
>  COMPAT_SYSCALL_DEFINE2(socketcall, int, call, u32 __user *, args)
>  {
> +	unsigned int len;
>  	int ret;
> -	u32 a[6];
> +	u32 a[AUDITSC_ARGS];
>  	u32 a0, a1;

Longest to shortest line for local variable declarations please.
