From: Anderson Lizardo <anderson.lizardo-430g2QfJUUCGglJvpFV4uA@public.gmane.org>
Subject: Re: [patch] Bluetooth: fix ->alloc_skb() error checking
Date: Mon, 16 Dec 2013 16:35:25 -0400
Message-ID: <CAJdJm_O9q3YgpjTQexbLvMm8ViViu+MrmRCqPwQDDUzaxVQYUg@mail.gmail.com>
References: <20131216202857.GB19601@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131216202857.GB19601-mgFCXtclrQlZLf2FXnZxJA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dan,

On Mon, Dec 16, 2013 at 4:28 PM, Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> @@ -2413,8 +2413,8 @@ static struct sk_buff *l2cap_create_basic_pdu(struct l2cap_chan *chan,
>
>         skb = chan->ops->alloc_skb(chan, count + L2CAP_HDR_SIZE,
>                                    msg->msg_flags & MSG_DONTWAIT);
> -       if (IS_ERR(skb))
> -               return skb;
> +       if (skb)
> +               return ERR_PTR(-ENOMEM);

It should be "!skb" above right?

>
>         skb->priority = priority;
>

Best Regards,
-- 
Anderson Lizardo
Instituto Nokia de Tecnologia - INdT
Manaus - Brazil
