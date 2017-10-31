From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] hv_netvsc: reset net_device_ctx->nvdev
 with rcu_assign_pointer()
Date: Tue, 31 Oct 2017 07:09:58 -0700
Message-ID: <1509458998.3828.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031134204.15287-1-vkuznets@redhat.com>
         <20171031134204.15287-4-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@linuxdriverproject.org,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031134204.15287-4-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-31 at 14:42 +0100, Vitaly Kuznetsov wrote:
> RCU_INIT_POINTER() is not suitable here as it doesn't give us ordering
> guarantees (see the comment in rcupdate.h). This is also not a hotpath.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> ---
>  drivers/net/hyperv/netvsc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index bfc79698b8f4..12efb3e34775 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -560,7 +560,7 @@ void netvsc_device_remove(struct hv_device *device)
>  
>  	netvsc_revoke_buf(device, net_device);
>  
> -	RCU_INIT_POINTER(net_device_ctx->nvdev, NULL);
> +	rcu_assign_pointer(net_device_ctx->nvdev, NULL);

I see no point for this patch.

Setting a NULL pointer needs no barrier at all.
