From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: Re: [PATCH] hostap: do not return positive number on failure path
 in prism2_open()
Date: Mon, 05 Aug 2013 07:18:11 +0400
Message-ID: <51FF1973.7080807@ispras.ru>
References: <1375671750-2835-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Jouni Malinen <j@w1.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375671750-2835-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please ignore this mail, there is a misprint in signed-off line.
I will resend the patch.

On 08/05/2013 07:02 AM, Alexey Khoroshilov wrote:
> prism2_open() as an .ndo_open handler should not return positive numbers
> in case of failure, but it does return 1 in a couple of places.
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilorv@ispras.ru>
> ---
>  drivers/net/wireless/hostap/hostap_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
> index 15f0fad..e4f56ad 100644
> --- a/drivers/net/wireless/hostap/hostap_main.c
> +++ b/drivers/net/wireless/hostap/hostap_main.c
> @@ -667,7 +667,7 @@ static int prism2_open(struct net_device *dev)
>  	if (local->no_pri) {
>  		printk(KERN_DEBUG "%s: could not set interface UP - no PRI "
>  		       "f/w\n", dev->name);
> -		return 1;
> +		return -ENODEV;
>  	}
>  
>  	if ((local->func->card_present && !local->func->card_present(local)) ||
> @@ -682,7 +682,7 @@ static int prism2_open(struct net_device *dev)
>  		printk(KERN_WARNING "%s: could not enable MAC port\n",
>  		       dev->name);
>  		prism2_close(dev);
> -		return 1;
> +		return -ENODEV;
>  	}
>  	if (!local->dev_enabled)
>  		prism2_callback(local, PRISM2_CALLBACK_ENABLE);
