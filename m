From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] rose: use %*ph specifier
Date: Fri, 05 Sep 2014 21:23:40 +0400
Message-ID: <5409F19C.7010209@cogentembedded.com>
References: <1409929311-3225-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1409929311-3225-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/05/2014 07:01 PM, Andy Shevchenko wrote:

> Instead of dereference each byte let's use %*ph specifier in the printk()
> calls.

> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>   net/rose/rose_link.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
> index bc55142..ce60771 100644
> --- a/net/rose/rose_link.c
> +++ b/net/rose/rose_link.c
> @@ -160,7 +160,7 @@ void rose_link_rx_restart(struct sk_buff *skb, struct rose_neigh *neigh, unsigne
>   		break;
>
>   	case ROSE_DIAGNOSTIC:
> -		printk(KERN_WARNING "ROSE: received diagnostic #%d - %02X %02X %02X\n", skb->data[3], skb->data[4], skb->data[5], skb->data[6]);
> +		pr_warn("ROSE: received diagnostic #%d - %4ph\n", skb->data + 3);

    Er, this doesn't seem right. The equivalent code would be:

		pr_warn("ROSE: received diagnostic #%d - %3ph\n", skb->data[3], skb->data + 4);

WBR, Sergei

