From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH 0/4] Add a driver for the ASIX AX88172A
Date: Mon, 9 Jul 2012 10:45:28 -0700
Message-ID: <CANEJEGuiw7w0aV47AnRQGzqBNCyAb7jj9t+Dh2XbzwMtV=doWw@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55498 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522Ab2GIRpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 13:45:30 -0400
Received: by yhmm54 with SMTP id m54so11151343yhm.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 10:45:29 -0700 (PDT)
In-Reply-To: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian,
Here's my $0.02 response to your questions.

On Fri, Jul 6, 2012 at 4:33 AM, Christian Riesch
<christian.riesch@omicron.at> wrote:
...
> I have a few questions:
>
> 1) Is it ok to factor out the common code like I did? Or should
>    it go into a separate kernel module?

I think it's ok. I'd rather not see additional kernel modules unless
the driver is substantially different.


> 2) phylib/usbnet: Currently I have an empty .status function
>    in my const struct driver_info ax88172a_info. I think this
>    notifies me of a link change, right? I don't know
>    what I should do in this function. Trigger the phy state machine
>    like a phy interrupt would do, since link changes are handled
>    by the phy state machine?

I don't see any Documentation for this entry point. My reading of the
code is driver_info->status (include/linux/usb/usbnet.h) is to poll
current link status from URBs. See  usbnet_probe()  (calls
init_status()) and intr_complete() (calls your stub).  I also looked
at usbnet_cdc_status() in cdc_ethernet.c. Maybe other drivers are
better examples.

hth,
grant
