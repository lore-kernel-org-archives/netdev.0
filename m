From: DaeSeok Youn <daeseok.youn@gmail.com>
Subject: Re: [PATCH 1/2] nfc: fix NULL pointer dereference
Date: Mon, 14 Apr 2014 11:19:41 +0900
Message-ID: <CAHb8M2BrbMFL-aUsBz6BjDzqJ1jYRBi557PB1kxcouo3_B8Jpg@mail.gmail.com>
References: <20540404.Au0OUqzobS@daeseok-laptop.cloud.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: aloisio.almeida@openbossa.org, sameo@linux.intel.com,
	linux-wireless@vger.kernel.org, linux-nfc@lists.01.org,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, lauro.venancio@openbossa.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20540404.Au0OUqzobS@daeseok-laptop.cloud.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Can you review this patch?

Thanks.
Daeseok Youn

2014-04-02 16:55 GMT+09:00 Daeseok Youn <daeseok.youn@gmail.com>:
>
> dev is NULL when nfc_get_device() is failed but
> dev is used for handling error.
>
> coccicheck says:
>  net/nfc/netlink.c:1092:21-24: ERROR:
> dev is NULL but dereferenced.
>
> Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>
> ---
>  net/nfc/netlink.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
> index 43cb1c1..b2ad570 100644
> --- a/net/nfc/netlink.c
> +++ b/net/nfc/netlink.c
> @@ -1026,10 +1026,8 @@ static int nfc_genl_llc_sdreq(struct sk_buff *skb, struct genl_info *info)
>         idx = nla_get_u32(info->attrs[NFC_ATTR_DEVICE_INDEX]);
>
>         dev = nfc_get_device(idx);
> -       if (!dev) {
> -               rc = -ENODEV;
> -               goto exit;
> -       }
> +       if (!dev)
> +               return -ENODEV;
>
>         device_lock(&dev->dev);
>
> --
> 1.7.4.4
>
>
