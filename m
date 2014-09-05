From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rose: use %*ph specifier
Date: Fri, 05 Sep 2014 08:52:30 -0700
Message-ID: <1409932350.26422.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409931138-25447-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1409931138-25447-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-09-05 at 18:32 +0300, Andy Shevchenko wrote:
> Instead of dereference each byte let's use %*ph specifier in the printk()
> calls.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
> - Since v1:
> - compile tested
> - fix a wrong argument list
>  net/rose/rose_link.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
> index bc55142..e873d7d 100644
> --- a/net/rose/rose_link.c
> +++ b/net/rose/rose_link.c
> @@ -160,7 +160,8 @@ void rose_link_rx_restart(struct sk_buff *skb, struct rose_neigh *neigh, unsigne
>  		break;
>  
>  	case ROSE_DIAGNOSTIC:
> -		printk(KERN_WARNING "ROSE: received diagnostic #%d - %02X %02X %02X\n", skb->data[3], skb->data[4], skb->data[5], skb->data[6]);
> +		pr_warn("ROSE: received diagnostic #%d - %3ph\n", skb->data[3],
> +			skb->data + 4);
>  		break;
>  
>  	default:

This looks better ;)

Acked-by: Eric Dumazet <edumazet@google.com>


