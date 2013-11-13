From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] usbnet: fix status interrupt urb handling
Date: Wed, 13 Nov 2013 10:09:56 +0100
Message-ID: <87r4akoefv.fsf@nemi.mork.no>
References: <1384270481-30972-1-git-send-email-nbd@openwrt.org>
	<1384329672.5724.6.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384329672.5724.6.camel-B2T3B9s34ElbnMAlSieJcQ@public.gmane.org> (Oliver Neukum's
	message of "Wed, 13 Nov 2013 09:01:12 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:

> On Tue, 2013-11-12 at 16:34 +0100, Felix Fietkau wrote:
>> Since commit 7b0c5f21f348a66de495868b8df0284e8dfd6bbf
>> "sierra_net: keep status interrupt URB active", sierra_net triggers
>> status interrupt polling before the net_device is opened (in order t=
o
>> properly receive the sync message response).
>>=20
>> To be able to receive further interrupts, the interrupt urb needs to=
 be
>> re-submitted, so this patch removes the bogus check for netif_runnin=
g().
>
> And what about the other drivers for whom this patch means added
> traffic? This fix is done with a sledge hammer and cares only about
> some drivers.

usbnet_stop calls usbnet_status_stop which kills the status URB, unless
the driver explicitly asked for it not to be killed.  And the callback
properly returns on status =3D=3D -ENOENT, before the lines in question=
=2E

So I think Felix is right.   None of the other drivers will ever hit th=
e
code he deletes. It only affects sierra_net, and that is unwanted.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
