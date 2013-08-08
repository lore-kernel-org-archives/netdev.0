From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v3 4/4] USBNET: ax88179_178a: enable tso if usb host
 supports sg dma
Date: Fri, 9 Aug 2013 07:48:39 +0800
Message-ID: <CACVXFVMWWcf5duqU9_NB6QMzN1mxE6HfHJ6Aco1u3+4+x7u8JA@mail.gmail.com>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
	<1375750370-18194-5-git-send-email-ming.lei@canonical.com>
	<1375791737.4457.98.camel@edumazet-glaptop>
	<CANEJEGvbS=o-942tFJTDzpNvgaB=KUZcBwzJCU-7OHaAF-aQFQ@mail.gmail.com>
	<CACVXFVOOQZ8mtDXtCE669vEo=jA56g-ADzTZkGLLupZ5D4Z==A@mail.gmail.com>
	<CANEJEGvvxi83=b+NGTzsVpJw5fE5nb-R0BRWRJ2gz7bF5-H5AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:58817 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758215Ab3HHXsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 19:48:42 -0400
In-Reply-To: <CANEJEGvvxi83=b+NGTzsVpJw5fE5nb-R0BRWRJ2gz7bF5-H5AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 9, 2013 at 1:25 AM, Grant Grundler <grundler@google.com> wrote:
> On Tue, Aug 6, 2013 at 5:41 PM, Ming Lei <ming.lei@canonical.com> wrote:
>> On Wed, Aug 7, 2013 at 1:09 AM, Grant Grundler <grundler@google.com> wrote:
> ...
>>> Following that logic, shouldn't all the features/hw_features settings
>>> be removed from reset code path?
>>
>> This patch won't touch other settings because that isn't related with
>> this patch.
>
> Sorry - I didn't mean to imply your patch should do this. I was hoping
> for a yes/no answer from you, Eric, or Dave.
>
> ...
>>> I'll note that any "hiccup" in the USB side that causes the device to
>>> get dropped and re-probed will cause the same symptom. There is
>>
>> I am afraid that PCI network devices' setting still won't survive unbound&
>> re-probed, will they?
>
> Correct - but PCI isn't as prone to "dropping off the bus" like USB

As far as I know, USB device still won't be disconnected easily, and
reset is possible, but we can make setting survive reset by implementing
.pre_reset() and .post_reset() callback. Or do you have other situation
of USB 'dropping off the bus'?

> is. Master aborts on some PCI systems is a "Fatal Exception" and AFAIK
> that's never been true for any USB device.

I mean rmmod & modprobe still can reset setting of one PCI network
device after powering on the device, can't it?


Thanks,
--
Ming Lei
