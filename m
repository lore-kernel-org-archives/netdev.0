From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [2.6.22] Fix a potential NULL pointer dereference in
 write_bulk_callback() in drivers/net/usb/pegasus.c
Date: Mon, 30 Jul 2007 15:45:04 -0400
Message-ID: <46AE3FC0.4020600@garzik.org>
References: <46A46160.9080508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: petkan@users.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Micah Gruber <micah.gruber@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52014 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S939024AbXG3TpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 15:45:10 -0400
In-Reply-To: <46A46160.9080508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Micah Gruber wrote:
> This patch fixes a potential null dereference bug where we dereference 
> pegasus before a null check. This patch simply moves the dereferencing 
> after the null check.
> 
> Signed-off-by: Micah Gruber <micah.gruber@gmail.com>
> 
> ---
> 
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -768,11 +768,13 @@
> static void write_bulk_callback(struct urb *urb)
> {
>        pegasus_t *pegasus = urb->context;
> -       struct net_device *net = pegasus->net;
> +       struct net_device *net;
> 
>        if (!pegasus)
>                return;
> 
> +       net = pegasus->net;
> +

applied (manually)


