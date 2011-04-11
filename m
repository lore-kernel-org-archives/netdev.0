From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH RESEND] uts: Set default hostname to "localhost", rather
 than "(none)"
Date: Mon, 11 Apr 2011 08:02:54 -0700
Message-ID: <20110411080254.403d3166@nehalam>
References: <20110411050155.GA2507@feather>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110411050155.GA2507@feather>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 10 Apr 2011 22:01:59 -0700
Josh Triplett <josh@joshtriplett.org> wrote:

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

It makes sense but this behavior has existed so long in Linux
that some distro might actually be depending on it.

-- 
