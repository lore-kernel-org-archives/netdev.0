From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] veth: Fix potential memory leak in veth_newlink
Date: Wed, 27 Apr 2016 12:57:14 +0200
Message-ID: <57209B0A.8070800@cumulusnetworks.com>
References: <1461753739-4803-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
	"David S. Miller" <davem@davemloft.net>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461753739-4803-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/27/2016 12:42 PM, Haishuang Yan wrote:
> Free peer netdev when failed to configure peer link or register dev.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  drivers/net/veth.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index f37a6e6..8bb9fb8 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -472,7 +472,6 @@ err_register_dev:
>  	/* nothing to do */
>  err_configure_peer:
>  	unregister_netdevice(peer);
> -	return err;
>  
>  err_register_peer:
>  	free_netdev(peer);
> 

No, it won't leak. unregister_netdevice() will queue it on the todo list and at
the next rtnl unlock the peer device will get freed.
In fact calling it like this you'll hit BUG_ON(dev->reg_state != NETREG_UNREGISTERED) in
free_netdev so I guess you didn't even test your patch.
