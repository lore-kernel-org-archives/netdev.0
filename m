From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: respin of hso patches for linux-2.6.28-rc6 hso_mutex.patch [patch 4/6]
Date: Mon, 24 Nov 2008 17:49:34 +0100
Message-ID: <8AC8EE6D-6C6D-41D6-806E-68646549710C@holtmann.org>
References: <492ABECF.5050307@option.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:59858 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbYKXQto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 11:49:44 -0500
In-Reply-To: <492ABECF.5050307@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Denis,

> A new structure hso_mutex_table had to be declared statically
> & used as as hso_device mutex_lock(&serial->parent->mutex) etc
> is freed in hso_serial_open & hso_serial_close by kref_put while
> the mutex is still in use.
> This is a substantial change but should make the driver much stabler.
> Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
> ---
> Index: linux-2.6.28-rc6.patches/drivers/net/usb/hso.c
> ===================================================================
> --- linux-2.6.28-rc6.patches.orig/drivers/net/usb/hso.c	2008-11-24  
> 14:19:17.000000000 +0100
> +++ linux-2.6.28-rc6.patches/drivers/net/usb/hso.c	2008-11-24  
> 14:59:29.000000000 +0100
> @@ -230,6 +230,11 @@
> 	struct work_struct    retry_unthrottle_workqueue;
> };
>
> +struct hso_mutex_t {
> +	struct mutex mutex;
> +	u8 allocated;
> +};
> +
> struct hso_device {
> 	union {
> 		struct hso_serial *dev_serial;
> @@ -248,7 +253,7 @@
>
> 	struct device *dev;
> 	struct kref ref;
> -	struct mutex mutex;
> +	struct hso_mutex_t *mutex;
> };

this looks pretty ugly to me. Can we not find a more elegant way to  
solve this problem?   It might involve fixing or changing the TTY  
layer, but that is actually fine.

Regards

Marcel

