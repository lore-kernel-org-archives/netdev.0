From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Cleanup usbnet_probe() return value handling
Date: Tue, 10 Jul 2007 12:42:29 -0400
Message-ID: <4693B6F5.6070603@garzik.org>
References: <87lkdyx19a.fsf@nanv.dk> <200707020914.38479.david-b@pacbell.net> <87sl86juel.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60186 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754846AbXGJQmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:42:37 -0400
In-Reply-To: <87sl86juel.fsf@p4.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
>>>>>> "David" == David Brownell <david-b@pacbell.net> writes:
> 
> Hi,
> 
>  David> I'd rather see the later test updated to match this one.
>  David> (Good catch!)
> 
>  David> The return convention is "negative means error".  There's
>  David> code in USB which has multiple nonnegative success codes.
> 
> Ok, updated patch does that instead.
> 
>  David> In particular usb_control_msg(), which would very naturally
>  David> used as the body of a bind() method, returns negative or
>  David> the number of bytes transferred.
> 
> Yeah, that was the original problem in my dm9601 driver.
> 
> usbnet_probe() handles a positive return value from the driver bind()
> function as success, but will later only setup the status handler if the
> return value was zero, leading to confusion. Patch adjusts this to accept
> positive values as success in both checks.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> ---
>  drivers/net/usb/usbnet.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied


