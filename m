From: Grant Grundler <grundler@google.com>
Subject: Re: [PATCH v3 4/4] USBNET: ax88179_178a: enable tso if usb host
 supports sg dma
Date: Thu, 8 Aug 2013 17:18:16 -0700
Message-ID: <CANEJEGsqGFCLXBUT_3SEd4Ej9g8XFOYZwm9omscNvJgz7MXUHg@mail.gmail.com>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
	<1375750370-18194-5-git-send-email-ming.lei@canonical.com>
	<1375791737.4457.98.camel@edumazet-glaptop>
	<CANEJEGvbS=o-942tFJTDzpNvgaB=KUZcBwzJCU-7OHaAF-aQFQ@mail.gmail.com>
	<CACVXFVOOQZ8mtDXtCE669vEo=jA56g-ADzTZkGLLupZ5D4Z==A@mail.gmail.com>
	<CANEJEGvvxi83=b+NGTzsVpJw5fE5nb-R0BRWRJ2gz7bF5-H5AA@mail.gmail.com>
	<CACVXFVMWWcf5duqU9_NB6QMzN1mxE6HfHJ6Aco1u3+4+x7u8JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:42265 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966947Ab3HIASQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 20:18:16 -0400
Received: by mail-ob0-f177.google.com with SMTP id f8so1663389obp.36
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 17:18:16 -0700 (PDT)
In-Reply-To: <CACVXFVMWWcf5duqU9_NB6QMzN1mxE6HfHJ6Aco1u3+4+x7u8JA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming,
We are splitting hairs now. :) I want to be clear I think your changes
are good and the rest of this conversation is just to learn something
new.

On Thu, Aug 8, 2013 at 4:48 PM, Ming Lei <ming.lei@canonical.com> wrote:
> On Fri, Aug 9, 2013 at 1:25 AM, Grant Grundler <grundler@google.com> wrote:
...
>>> I am afraid that PCI network devices' setting still won't survive unbound&
>>> re-probed, will they?
>>
>> Correct - but PCI isn't as prone to "dropping off the bus" like USB
>
> As far as I know, USB device still won't be disconnected easily, and
> reset is possible, but we can make setting survive reset by implementing
> .pre_reset() and .post_reset() callback. Or do you have other situation
> of USB 'dropping off the bus'?

So far only older USB core bugs like this one:
    https://codereview.chromium.org/4687002/show

I agree USB won't be disconnected easily.

>> is. Master aborts on some PCI systems is a "Fatal Exception" and AFAIK
>> that's never been true for any USB device.
>
> I mean rmmod & modprobe still can reset setting of one PCI network
> device after powering on the device, can't it?

Definitely. But this isn't something that will "randomly" happen and
will leave tracks all over the place of it happening. So I'm not
worried about trying to debug this scenario.

thanks,
grant

>
>
> Thanks,
> --
> Ming Lei
