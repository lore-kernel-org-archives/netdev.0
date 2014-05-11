From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next 1/4] net: cdc_mbim: optionally use VLAN ID 4094 for IP session 0
Date: Sun, 11 May 2014 10:28:55 +0200
Message-ID: <87r440oh14.fsf@nemi.mork.no>
References: <1399760243-26625-1-git-send-email-bjorn@mork.no>
	<1399760243-26625-2-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399760243-26625-2-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
 (=?utf-8?Q?=22Bj=C3=B8rn?= Mork"'s
	message of "Sun, 11 May 2014 00:17:20 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:

> @@ -164,12 +211,24 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct=
 usbnet *dev, struct sk_buff *skb
>  			skb_pull(skb, ETH_HLEN);
>  		}
> =20
> +		/* Is IP session <0> tagged too? */
> +		if (!tci && info->flags & FLAG_IPS0_VLAN) {
> +			/* drop all untagged packets */
> +			if (!tci)
> +				goto error;
> +			/* map MBIM_IPS0_VID to IPS<0> */
> +			if (tci =3D=3D MBIM_IPS0_VID)
> +				tci =3D 0;
> +		}

This is embarrassing.  I made a mess of this, "tidying" it up while
doing the final rebase before submitting.  And obviously never tested
the final result...

Will fix and submbit a new version.  Sorry for the noise.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
