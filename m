From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RESEND] dm9601: don't do usb transfers of data on stack
Date: Fri, 11 Jul 2008 14:00:37 +0200
Message-ID: <200807111400.38312.oliver@neukum.org>
References: <87mykoircs.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87mykoircs.fsf-uXGAPMMVk8amE9MCos8gUmSdvHPH+/yF@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag 11 Juli 2008 13:37:39 schrieb Peter Korsgaard:
> dm_{read,write}_shared_word() were doing USB transfers of data on stack,
> which isn't allowed. Fix it by using the usbnet->data area like in
> dm9601_set_multicast().

You cannot do this. You've identified the bug correctly, but the fix
is incorrect. Doing DMA on non coherent architectures means that
any cacheline the buffer shares must not be touched while DMA
may be running. If you embed the buffer into struct usbnet, how could
you meet the guarantee?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
