From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH RESEND] uts: Set default hostname to "localhost", rather
 than "(none)"
Date: Mon, 11 Apr 2011 07:39:19 -0500
Message-ID: <20110411123919.GA17405@hallyn.com>
References: <20110411050155.GA2507@feather>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110411050155.GA2507@feather>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Josh Triplett (josh@joshtriplett.org):
> The "hostname" tool falls back to setting the hostname to "localhost" if
> /etc/hostname does not exist.  Distribution init scripts have the same
> fallback.  However, if userspace never calls sethostname, such as when
> booting with init=/bin/sh, or otherwise booting a minimal system without
> the usual init scripts, the default hostname of "(none)" remains,
> unhelpfully appearing in various places such as prompts
> ("root@(none):~#") and logs.  Furthrmore, "(none)" doesn't typically
> resolve to anything useful, while "localhost" does.
> 
> Change the default hostname to "localhost".  This removes the need for
> the standard fallback, provides a useful default for systems that never
> call sethostname, and makes minimal systems that much more useful with
> less configuration.
> 
> Signed-off-by: Josh Triplett <josh@joshtriplett.org>

Seems good to me.  I'd have no idea if there were valid reasons to object
to such a thing so my ack means nothing, but

Acked-by: Serge Hallyn <serge.hallyn@ubuntu.com>

thanks,
-serge

> ---
> 
> Looked at "(none)" one too many times, and figured I ought to do
> something about it.
> 
> Resending, and adding CCs for networking and UTS.
> 
>  include/linux/uts.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/uts.h b/include/linux/uts.h
> index 73eb1ed..610bec2 100644
> --- a/include/linux/uts.h
> +++ b/include/linux/uts.h
> @@ -9,7 +9,7 @@
>  #endif
>  
>  #ifndef UTS_NODENAME
> -#define UTS_NODENAME "(none)"	/* set by sethostname() */
> +#define UTS_NODENAME "localhost"	/* set by sethostname() */
>  #endif
>  
>  #ifndef UTS_DOMAINNAME
> -- 
> 1.7.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
