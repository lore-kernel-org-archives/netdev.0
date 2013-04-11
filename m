From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 20:59:05 +0800
Message-ID: <CACVXFVPPzva+EwjNdxWsg4FufCc0zzzzvhGH_nLv479vT8VcxQ@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<28454387.MvMlbQoOly@linux-5eaq.site>
	<CACVXFVORLr+cRV6uG0-CbYnQ4DKucforyVFcLq+B8Xwz5bVguw@mail.gmail.com>
	<1735684.e8eeVoUkuq@linux-5eaq.site>
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
Received: from mail-vc0-f178.google.com ([209.85.220.178]:41296 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081Ab3DKM7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 08:59:07 -0400
In-Reply-To: <1735684.e8eeVoUkuq@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 8:28 PM, Oliver Neukum <oliver@neukum.org> wrote:
> On Thursday 11 April 2013 20:11:13 Ming Lei wrote:
>> On Thu, Apr 11, 2013 at 7:14 PM, Oliver Neukum <oliver@neukum.org> wrote:
>> >
>> > Sorry, I misunderstood.
>>
>> No problem, :-)
>>
>> >
>> > Task A                                  Task B                          queue
>> >
>> > queue work
>> >                                                 request a reset
>> >                                                                                         allocate memory and block
>> >                                                 cancel the work
>> >                                                                                         shit happened
>>
>> If I understand the case correctly, the above deadlock can be avoided
>> by canceling rx/tx URBs at the end of pre_reset() or usbnet_disconnect(),
>
> No. cancel_work_sync() must wait for the work. The work will not finish.

The work will complete when memory is reclaimed, and the rx/tx path is
still working, so memory reclaim can continue and the deadlock may not
be caused, may it?


Thanks,
-- 
Ming Lei
