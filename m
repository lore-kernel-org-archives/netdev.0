From: Ryan Mallon <rmallon@gmail.com>
Subject: Re: [PATCH 01/12] ping.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:59:52 +1000
Message-ID: <523FA098.9050200@gmail.com>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/09/13 03:32, Joe Perches wrote:
> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
> 
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

This seems like a lot of code churn for very little benefit. At a quick
glance:

  git grep extern include/ | wc -l
  11427

Not all of those will need to be removed, but that is still a huge
number to change, and doesn't include extern usage in C files or local
headers. You are probably never going to remove all the instances, so
what is the point of just randomly doing a handful?

~Ryan

> ---
>  include/net/ping.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/ping.h b/include/net/ping.h
> index 5db0224..3f67704 100644
> --- a/include/net/ping.h
> +++ b/include/net/ping.h
> @@ -103,8 +103,8 @@ void ping_seq_stop(struct seq_file *seq, void *v);
>  int ping_proc_register(struct net *net, struct ping_seq_afinfo *afinfo);
>  void ping_proc_unregister(struct net *net, struct ping_seq_afinfo *afinfo);
>  
> -extern int __init ping_proc_init(void);
> -extern void ping_proc_exit(void);
> +int __init ping_proc_init(void);
> +void ping_proc_exit(void);
>  #endif
>  
>  void __init ping_init(void);
> 
