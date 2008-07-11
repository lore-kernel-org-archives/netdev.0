From: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Subject: Re: [PATCH RESEND] dm9601: don't do usb transfers of data on stack
Date: Fri, 11 Jul 2008 14:17:58 +0200
Message-ID: <87vdzcehs9.fsf@macbook.be.48ers.dk>
References: <87mykoircs.fsf@macbook.be.48ers.dk>
	<200807111400.38312.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200807111400.38312.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> (Oliver Neukum's message of "Fri\, 11 Jul 2008 14\:00\:37 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>>>> "Oliver" == Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:

 >> dm_{read,write}_shared_word() were doing USB transfers of data on stack,
 >> which isn't allowed. Fix it by using the usbnet->data area like in
 >> dm9601_set_multicast().

 Oliver> You cannot do this. You've identified the bug correctly, but
 Oliver> the fix is incorrect. Doing DMA on non coherent architectures
 Oliver> means that any cacheline the buffer shares must not be
 Oliver> touched while DMA may be running. If you embed the buffer
 Oliver> into struct usbnet, how could you meet the guarantee?

Ahh. So kmalloc() / kfree() around the usb_control_msg isn dm_read /
dm_write is the way to go?

-- 
Bye, Peter Korsgaard
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
