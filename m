From: Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] nfc: Ensure presence of required attributes in the
 activate_target netlink handler
Date: Wed, 24 May 2017 10:05:48 -0700
Message-ID: <CAGXu5jK3aX-AFXCk9=hhX49scgGOHBYXocsNJb8u+ienMuM65g@mail.gmail.com>
References: <20170524104226.14841-1-mjurczyk@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170524104226.14841-1-mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 24, 2017 at 3:42 AM, Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> Check that the NFC_ATTR_TARGET_INDEX and NFC_ATTR_PROTOCOLS attributes (in
> addition to NFC_ATTR_DEVICE_INDEX) are provided by the netlink client
> prior to accessing them. This prevents potential unhandled NULL pointer
> dereference exceptions which can be triggered by malicious user-mode
> programs, if they omit one or both of these attributes.
>
> Signed-off-by: Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Acked-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

-Kees

> ---
>  net/nfc/netlink.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
> index 6b0850e63e09..b251fb936a27 100644
> --- a/net/nfc/netlink.c
> +++ b/net/nfc/netlink.c
> @@ -907,7 +907,9 @@ static int nfc_genl_activate_target(struct sk_buff *skb, struct genl_info *info)
>         u32 device_idx, target_idx, protocol;
>         int rc;
>
> -       if (!info->attrs[NFC_ATTR_DEVICE_INDEX])
> +       if (!info->attrs[NFC_ATTR_DEVICE_INDEX] ||
> +           !info->attrs[NFC_ATTR_TARGET_INDEX] ||
> +           !info->attrs[NFC_ATTR_PROTOCOLS])
>                 return -EINVAL;
>
>         device_idx = nla_get_u32(info->attrs[NFC_ATTR_DEVICE_INDEX]);
> --
> 2.13.0.219.gdb65acc882-goog
>



-- 
Kees Cook
Pixel Security
