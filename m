From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH rdma-next 08/19] RDMA/core: Expose translation from device name to ib_device
Date: Wed, 21 Jun 2017 09:09:27 -0500
Message-ID: <022401d2ea97$fe0ecdb0$fa2c6910$@opengridcomputing.com>
References: <20170621060528.3752-1-leon@kernel.org> <20170621060528.3752-9-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "'Chien Tin Tung'" <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "'Stephen Hemminger'" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        "'Jiri Pirko'" <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "'Ariel Almog'" <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "'Linux Netdev'" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "'Leon Romanovsky'" <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "'Leon Romanovsky'" <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "'Doug Ledford'" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621060528.3752-9-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> Provide ability to convert from device name to ib_device for the
> IB/core users.
> 
> Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/infiniband/core/core_priv.h | 1 +
>  drivers/infiniband/core/device.c    | 3 +--
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/infiniband/core/core_priv.h
> b/drivers/infiniband/core/core_priv.h
> index 4a150c4be175..049ccbfca988 100644
> --- a/drivers/infiniband/core/core_priv.h
> +++ b/drivers/infiniband/core/core_priv.h
> @@ -184,4 +184,5 @@ int ib_nl_handle_set_timeout(struct sk_buff *skb,
>  int ib_nl_handle_ip_res_resp(struct sk_buff *skb,
>  			     struct netlink_callback *cb);
> 
> +struct ib_device *__ib_device_get_by_name(const char *name);
>  #endif /* _CORE_PRIV_H */
> diff --git a/drivers/infiniband/core/device.c
b/drivers/infiniband/core/device.c
> index 7a799fc90348..4ec1b24258de 100644
> --- a/drivers/infiniband/core/device.c
> +++ b/drivers/infiniband/core/device.c
> @@ -124,7 +124,7 @@ static int ib_device_check_mandatory(struct ib_device
> *device)
>  	return 0;
>  }
> 
> -static struct ib_device *__ib_device_get_by_name(const char *name)
> +struct ib_device *__ib_device_get_by_name(const char *name)
>  {
>  	struct ib_device *device;
> 
>

Nit: Why is this function prefixed with __?   Perhaps now it should just be
ib_device_get_by_name()?


Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
