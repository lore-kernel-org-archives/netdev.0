From: Grant Grundler <grundler@google.com>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Thu, 20 Mar 2014 09:35:23 -0700
Message-ID: <CANEJEGu3j4a6LOiyD-Qbs5nX4wc4spWQB3ZukmEa1J6VPUg+=g@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	<1394529263.16128.6.camel@linux-fkkt.site>
	<CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	<CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
	<1395093343.3961.2.camel@linux-fkkt.site>
	<CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ@mail.gmail.com>
	<CAODwPW-E-3HcXCGEmp9JpW6hU-Xt-FHwBtqeSSTDGaRPqO49Sw@mail.gmail.com>
	<CANEJEGscbVF3gRLNtTAcRSpHGVm1iDDKEeBscXcwj2-YdkiDXA@mail.gmail.com>
	<CANEJEGtZF30=bqkErvi1CFZLbk=PJ-p_gKf9eBGU7sWwJcrefg@mail.gmail.com>
	<1395299705.5432.12.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>,
	Julius Werner <jwerner@chromium.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:57605 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbaCTQfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 12:35:24 -0400
Received: by mail-oa0-f53.google.com with SMTP id j17so1204413oag.12
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 09:35:23 -0700 (PDT)
In-Reply-To: <1395299705.5432.12.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2014 at 12:15 AM, Oliver Neukum <oneukum@suse.de> wrote:
...
> I have an idea. Could you test this patch?
...
> -       if (dev->wait) {
..
> +       if (waitqueue_active(&dev->wait)) {

Yes - building new image now (and transfer to USB and boot from USB).
Should know in an hour or so (doing other things in parallel).

I was sure the problem is in usbnet_bh() since that's the only code
change I'm actually exercising (so far). The way I was reading the
code, we might see extra wake_up calls...but there is clearly more
going on.

Can you please explain why we need to check if the waitqueue is active?

This patch should also add a comment to hint why waitqueue_active()
must be called.
Why? Several experienced people looked at the code and didn't see the
problem including the original author of the patch.

thanks,
grant
