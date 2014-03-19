From: Julius Werner <jwerner@chromium.org>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Tue, 18 Mar 2014 18:09:27 -0700
Message-ID: <CAODwPW-E-3HcXCGEmp9JpW6hU-Xt-FHwBtqeSSTDGaRPqO49Sw@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	<1394529263.16128.6.camel@linux-fkkt.site>
	<CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	<CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
	<1395093343.3961.2.camel@linux-fkkt.site>
	<CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oliver Neukum <oneukum@suse.de>,
	Julius Werner <jwerner@chromium.org>,
	netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:35555 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757668AbaCSBJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 21:09:28 -0400
Received: by mail-qc0-f177.google.com with SMTP id w7so8767233qcr.8
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 18:09:28 -0700 (PDT)
In-Reply-To: <CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I tried adding the following change on top of your patch but believe
> the plumbing still isn't quite correct since the USB device (eth0) is
> reporting a link but no TX or RX of traffic:
>  @@ -805,6 +807,9 @@ int usbnet_open (struct net_device *net)
>                 goto done;
>         }
>
> +       /* usbnet_bh() expects the spinlock to be initialized. */
> +       init_waitqueue_head(&dev->wait);
> +
>         /* hard_mtu or rx_urb_size may change in reset() */
>         usbnet_update_max_qlen(dev);


I think a better place for this would be in usbnet_probe() (together
with all the other dev->xxx initialization). I'm not quite sure how
that could cause the transfer problems you are seeing, but at least
you will no longer initialize the waitqueue multiple times on multiple
usbnet_open (which is probably a bad idea).
