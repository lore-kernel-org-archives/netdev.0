From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH RESEND] dm9601: don't do usb transfers of data on stack
Date: Fri, 11 Jul 2008 14:22:55 +0200
Message-ID: <200807111422.56406.oliver@neukum.org>
References: <87mykoircs.fsf@macbook.be.48ers.dk> <200807111400.38312.oliver@neukum.org> <87vdzcehs9.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:35606 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230AbYGKMWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 08:22:17 -0400
In-Reply-To: <87vdzcehs9.fsf@macbook.be.48ers.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag 11 Juli 2008 14:17:58 schrieb Peter Korsgaard:
> >>>>> "Oliver" == Oliver Neukum <oliver@neukum.org> writes:
> 
>  >> dm_{read,write}_shared_word() were doing USB transfers of data on stack,
>  >> which isn't allowed. Fix it by using the usbnet->data area like in
>  >> dm9601_set_multicast().
> 
>  Oliver> You cannot do this. You've identified the bug correctly, but
>  Oliver> the fix is incorrect. Doing DMA on non coherent architectures
>  Oliver> means that any cacheline the buffer shares must not be
>  Oliver> touched while DMA may be running. If you embed the buffer
>  Oliver> into struct usbnet, how could you meet the guarantee?
> 
> Ahh. So kmalloc() / kfree() around the usb_control_msg isn dm_read /
> dm_write is the way to go?

The buffer should be allocated with kmalloc. That doesn't mean it has to
be allocated each time the function is called. If several drivers do this, the
best fix is to modify struct usbnet so that it contains only a pointer to the
buffer, not the buffer itself and modify drivers accordingly.

	Regards
		Oliver
