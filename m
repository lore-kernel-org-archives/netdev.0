From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] [2.6.22] Fix a potential NULL pointer dereference in
 write_bulk_callback() in drivers/net/usb/pegasus.c
Date: Tue, 24 Jul 2007 15:57:28 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707241557160.6699@bender.nucleusys.com>
References: <46A46160.9080508@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: petkan@users.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com
To: Micah Gruber <micah.gruber@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n152-u15.estnet.bg ([89.253.152.15]:3024 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754526AbXGXNAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 09:00:15 -0400
In-Reply-To: <46A46160.9080508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK :-)


cheers,
Petko


On Mon, 23 Jul 2007, Micah Gruber wrote:

> This patch fixes a potential null dereference bug where we dereference 
> pegasus before a null check. This patch simply moves the dereferencing after 
> the null check.
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
>       pegasus_t *pegasus = urb->context;
> -       struct net_device *net = pegasus->net;
> +       struct net_device *net;
>
>       if (!pegasus)
>               return;
>
> +       net = pegasus->net;
> +
>       if (!netif_device_present(net) || !netif_running(net))
>               return;
>
