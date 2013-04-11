From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 20:11:13 +0800
Message-ID: <CACVXFVORLr+cRV6uG0-CbYnQ4DKucforyVFcLq+B8Xwz5bVguw@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<3010836.mDNO71IiS7@linux-5eaq.site>
	<CACVXFVNHoBNpyRztp1Bu_41=YnszqQ3jQDw4j87Zd2hZM3r-VA@mail.gmail.com>
	<28454387.MvMlbQoOly@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f48.google.com ([209.85.212.48]:52234 "EHLO
	mail-vb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754657Ab3DKMLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 08:11:14 -0400
In-Reply-To: <28454387.MvMlbQoOly@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 7:14 PM, Oliver Neukum <oliver@neukum.org> wrote:
>
> Sorry, I misunderstood.

No problem, :-)

>
> Task A                                  Task B                          queue
>
> queue work
>                                                 request a reset
>                                                                                         allocate memory and block
>                                                 cancel the work
>                                                                                         shit happened

If I understand the case correctly, the above deadlock can be avoided
by canceling rx/tx URBs at the end of pre_reset() or usbnet_disconnect(),
then memory can still be reclaimed in queue context since rx/tx is still
workable. Right?


Thanks,
-- 
Ming Lei
