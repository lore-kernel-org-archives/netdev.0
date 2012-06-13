From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/7] usbnet: remove EVENT_DEV_OPEN flag
Date: Wed, 13 Jun 2012 17:21:40 +0800
Message-ID: <CACVXFVNkRbK8NhAbR0+dNNdbvZUNW7dyKw8fELz6csmZxSiTPQ@mail.gmail.com>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
	<CACVXFVPf+Q9i-Ju3GFapiTB2wEWZSBrZ2Gf=WHsLWfWfTnWGpA@mail.gmail.com>
	<CACVXFVOjPxK3X5RF7DVJsTj3g3MyKg_49qtaev=ZBthsjBC=OA@mail.gmail.com>
	<201206130940.54817.oliver@neukum.org>
	<87r4tjlio1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87r4tjlio1.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2012 at 4:28 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
>
> BTW, does the "&& (dev->net->flags & IFF_UP)" really make any
> difference, or could the test be simplified to
>
> =A0 =A0(netif_running(dev->net))

Neither netif_running(dev->net) nor  (dev->net->flags & IFF_UP)
is enough.

In the start of usbnet_open(), the usb device may be waken up and
usbnet_resume will see netif_running(dev->net) in the situation, so
may cause problem since the interface hasn't been UP yet.

If just checking on (dev->net->flags & IFF_UP), it still may cause
problem in usbnet_resume as pointed by Oliver.

So looks only checking on both netif_running(dev->net) and
(dev->net->flags & IFF_UP) is OK.

Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
