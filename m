From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 12:13:31 -0800
Message-ID: <1484252011.13165.0.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484251157-245538-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shannon Nelson <shannon.nelson@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1484251157-245538-1-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2017-01-12 at 11:59 -0800, Shannon Nelson wrote:
> Fix up a data alignment issue on sparc by swapping the order
> of the cookie byte array field with the length field in
> struct tcp_fastopen_cookie
> 
> This addresses log complaints like these:
>     log_unaligned: 113 callbacks suppressed
>     Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360
>     Kernel unaligned access at TPC[9764ac] tcp_try_fastopen+0x2ec/0x360
>     Kernel unaligned access at TPC[9764c8] tcp_try_fastopen+0x308/0x360
>     Kernel unaligned access at TPC[9764e4] tcp_try_fastopen+0x324/0x360
>     Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> ---
>  include/linux/tcp.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index fc5848d..95cda75 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -62,8 +62,8 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
>  
>  /* TCP Fast Open Cookie as stored in memory */
>  struct tcp_fastopen_cookie {
> -	s8	len;
>  	u8	val[TCP_FASTOPEN_COOKIE_MAX];
> +	s8	len;
>  	bool	exp;	/* In RFC6994 experimental option format */
>  };
>  

Strange... Do you have an explanation of why this patch would be
needed ? A compiler issue ?


s8 and u8 are bytes after all.




