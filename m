From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 4/7] usbnet: remove EVENT_DEV_OPEN flag
Date: Wed, 13 Jun 2012 10:28:46 +0200
Message-ID: <87r4tjlio1.fsf@nemi.mork.no>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
	<CACVXFVPf+Q9i-Ju3GFapiTB2wEWZSBrZ2Gf=WHsLWfWfTnWGpA@mail.gmail.com>
	<CACVXFVOjPxK3X5RF7DVJsTj3g3MyKg_49qtaev=ZBthsjBC=OA@mail.gmail.com>
	<201206130940.54817.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201206130940.54817.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> (Oliver Neukum's message
	of "Wed, 13 Jun 2012 09:40:54 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:
> Am Mittwoch, 13. Juni 2012, 06:47:18 schrieb Ming Lei:
>> On Wed, Jun 13, 2012 at 10:12 AM, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> w=
rote:
>> > On Wed, Jun 13, 2012 at 2:14 AM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>=
 wrote:
>> >> Am Dienstag, 12. Juni 2012, 03:19:42 schrieb Ming Lei:
>> >>> EVENT_DEV_OPEN is introduced to mark if the interface is opened =
or
>> >>> not, but we already have IFF_UP to handle it, so just
>> >>> remove the flag and use IFF_UP.
>> >>
>> >> When is IFF_UP cleared? The flag is tested in usbnet_resume(),
>> >
>> > The flag is cleared just after usbnet_stop completes.
>>=20
>> Looks we can use the below to replace EVENT_DEV_OPEN:
>>=20
>>      (netif_running((dev)->net) && ((dev)->net->flags & IFF_UP))
>
> That goes down a bit into the interna of the network code.
> If we do this, please encapsulated and with a big fat comment.

There are already plenty of places in usbnet.c where
netif_running(dev->net) is tested instead of EVENT_DEV_OPEN.
Why should the test in usbnet_resume be any different?

The only reason I see is that some devices might want to keep interrupt=
s
running without the netdev being up, but the current code doesn't
support that anyway.  So better implement it when there is a device and
driver needing it.

BTW, does the "&& (dev->net->flags & IFF_UP)" really make any
difference, or could the test be simplified to

    (netif_running(dev->net))





Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
