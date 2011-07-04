From: Harry Wei <jiaweiwei.xiyou@gmail.com>
Subject: Re: [PATCH 1/2] netpoll: Remove unused EXPORT_SYMBOLs of
 netpoll_poll and netpoll_poll_dev
Date: Mon, 4 Jul 2011 14:53:22 +0800
Message-ID: <20110704065320.GA2588@gmail.com>
References: <cover.1309482314.git.joe@perches.com>
 <282ce7d68b97c4dbfb759c1c0752e6cbddfeeafc.1309482314.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48421 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab1GDGxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 02:53:39 -0400
Content-Disposition: inline
In-Reply-To: <282ce7d68b97c4dbfb759c1c0752e6cbddfeeafc.1309482314.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2011 at 06:08:57PM -0700, Joe Perches wrote:
> Unused symbols waste space.
> 
> Commit 0e34e93177fb
> "(netpoll: add generic support for bridge and bonding devices)"
> added the symbol more than a year ago with the promise of "future use".
> 
> Because it is so far unused, remove it for now.
> It can be easily readded if or when it actually needs to be used.
> 
> cc: WANG Cong <amwang@redhat.com>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  include/linux/netpoll.h |    2 --
>  net/core/netpoll.c      |    6 ++----
>  2 files changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> index 79358bb..5dfa091 100644
> --- a/include/linux/netpoll.h
> +++ b/include/linux/netpoll.h
> @@ -40,8 +40,6 @@ struct netpoll_info {
>  	struct netpoll *netpoll;
>  };
>  
> -void netpoll_poll_dev(struct net_device *dev);
> -void netpoll_poll(struct netpoll *np);
>  void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
>  void netpoll_print_options(struct netpoll *np);
>  int netpoll_parse_options(struct netpoll *np, char *opt);
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 18d9cbd..4ce595e 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -177,7 +177,7 @@ static void service_arp_queue(struct netpoll_info *npi)
>  	}
>  }
>  
> -void netpoll_poll_dev(struct net_device *dev)
> +static void netpoll_poll_dev(struct net_device *dev)
Hi Joe,
You have removed the function declaration in include/linux/netpoll.h.
And you changed the function like 
static void netpoll_poll_dev(...)
{
	...
}
But i don't know its usage.
The 'static' before this function just says the active area of 'netpoll_poll_dev'
is in the file net/core/netpoll.c. What is the purpose? Could you please tell me?

Thanks in advance.

>  {
>  	const struct net_device_ops *ops;
>  
> @@ -208,13 +208,11 @@ void netpoll_poll_dev(struct net_device *dev)
>  
>  	zap_completion_queue();
>  }
> -EXPORT_SYMBOL(netpoll_poll_dev);
>  
> -void netpoll_poll(struct netpoll *np)
> +static void netpoll_poll(struct netpoll *np)
>  {
>  	netpoll_poll_dev(np->dev);
>  }
> -EXPORT_SYMBOL(netpoll_poll);
>  
>  static void refill_skbs(void)
>  {
> -- 
> 1.7.6.rc1
