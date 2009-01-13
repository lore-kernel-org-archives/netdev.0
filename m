From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH -tip] in6.h: extern's make no sense in userspace
Date: Tue, 13 Jan 2009 08:15:13 +0100
Message-ID: <20090113071513.GB20036@uranus.ravnborg.org>
References: <1231829859.3212.19.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, harvey.harrison@gmail.com,
	gorcunov@gmail.com, roque@di.fc.ul.pt,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinder@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756801AbZAMHNq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1231829859.3212.19.camel@jaswinder.satnam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 13, 2009 at 12:27:39PM +0530, Jaswinder Singh Rajput wrote:
> Impact: fix 2 make headers_check warnings:
> 
>  usr/include/linux/in6.h:47: extern's make no sense in userspace
>  usr/include/linux/in6.h:49: extern's make no sense in userspace
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> ---
>  include/linux/in6.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/in6.h b/include/linux/in6.h
> index bc49204..718bf21 100644
> --- a/include/linux/in6.h
> +++ b/include/linux/in6.h
> @@ -44,11 +44,11 @@ struct in6_addr
>   * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
>   * in network byte order, not in host byte order as are the IPv4 equivalents
>   */
> +#ifdef __KERNEL__
>  extern const struct in6_addr in6addr_any;
>  #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
>  extern const struct in6_addr in6addr_loopback;
>  #define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
> -#ifdef __KERNEL__

It looks wrong what IN6ADDR_ANY_INIT should be a kernel only symbol.
At least google had some hits on that symbol.

netdev people should know....

	Sam
