From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 14:28:43 +0200
Message-ID: <1735684.e8eeVoUkuq@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <28454387.MvMlbQoOly@linux-5eaq.site> <CACVXFVORLr+cRV6uG0-CbYnQ4DKucforyVFcLq+B8Xwz5bVguw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:56057 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765905Ab3DKM16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 08:27:58 -0400
In-Reply-To: <CACVXFVORLr+cRV6uG0-CbYnQ4DKucforyVFcLq+B8Xwz5bVguw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 April 2013 20:11:13 Ming Lei wrote:
> On Thu, Apr 11, 2013 at 7:14 PM, Oliver Neukum <oliver@neukum.org> wrote:
> >
> > Sorry, I misunderstood.
> 
> No problem, :-)
> 
> >
> > Task A                                  Task B                          queue
> >
> > queue work
> >                                                 request a reset
> >                                                                                         allocate memory and block
> >                                                 cancel the work
> >                                                                                         shit happened
> 
> If I understand the case correctly, the above deadlock can be avoided
> by canceling rx/tx URBs at the end of pre_reset() or usbnet_disconnect(),

No. cancel_work_sync() must wait for the work. The work will not finish.

	Regards
		Oliver
