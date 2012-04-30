From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usbnet: fix skb traversing races during unlink
Date: Mon, 30 Apr 2012 16:13:40 +0800
Message-ID: <CACVXFVPzZF1BTN+0frDh5EyQnpAvkPSbMEAhWmUw2OgaTEwF1g@mail.gmail.com>
References: <1335522095-9012-1-git-send-email-tom.leiming@gmail.com>
	<20120428.221832.360259077795872366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120428.221832.360259077795872366.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 29, 2012 at 10:18 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wr=
ote:
> From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Fri, 27 Apr 2012 18:21:35 +0800
>
>> +/*The caller must hold list->lock*/
>
> Please put spaces in your comments, like this:
>
> /* The caller must hold list->lock */
>
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*speedup unlink by blocking resubmit*/
>
> Same here.

OK, will do it.

>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_data *) skb->cb;
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_walk(q, skb) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_data=
 *) skb->cb;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->state !=3D unli=
nk_start)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D (struct sk_buff *)q)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> Please do not expose the internal details of SKB lists
> with a test like this. =A0Eventually this will all be
> converted to struct list_head and this kind of test
> will cause unnecessary pain for such a conversion.
>
> Instead, code it like this, as you would for a loop
> using list_for_each*() or similar:
>
> =A0 =A0 =A0 =A0skb_queue_walk(q, skb) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (condition)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto found;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0/* No matching entry. */
> =A0 =A0 =A0 =A0break;
> found:

Good suggestion, will do it.


Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
