From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 1/2] usbnet: allow status interrupt URB to always be active
Date: Tue, 15 Jan 2013 09:13:56 +0800
Message-ID: <CACVXFVO0b-SRn4H4OVSmifGafBtcneBeegQ7PwfAtuojgn_E-Q@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1357318096.5370.15.camel@dcbw.foobar.com>
	<2212516.GkG3xP33yG@linux-5eaq.site>
	<1357349193.19684.3.camel@dcbw.foobar.com>
	<CACVXFVOAjHMxRC=uok-OWPYjw-7D1MSnbaWo97LcGFAVRq+o2g@mail.gmail.com>
	<1358184201.1713.30.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oliver@neukum.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54691 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706Ab3AOBN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 20:13:59 -0500
In-Reply-To: <1358184201.1713.30.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 15, 2013 at 1:23 AM, Dan Williams <dcbw@redhat.com> wrote:
> On Fri, 2013-01-11 at 11:06 +0800, Ming Lei wrote:
>> I am curious who are interested in the 'custom Restart indication'
>> information after the interface is closed.
>
> It's actually before the interface is even opened.  It's really just a
> sync signal that's part of the driver's setup/initialization of the
> device.

OK, got it.

Considered that it is only required by Sierra, could you submit
the status URB in driver->bind and cancel it in driver->reset so
we can avoid touching usbnet core code(one simple change
might be to move init_status() before calling driver->info()
inside usbnet_probe())?

>
>> If sierra_net provides ways(such as read registers) to query the
>> indication event, you can just query the information and setup
>> the device in driver_info->reset() during device open, so you can
>> avoid submitting interrupt URB always.
>
> As far as I know, it does not, or at least Sierra hasn't released such
> information about the firmware API of their devices.

You are unlucky, :-)

In fact, many usbnet devices provide read command to query this kind of
information.


Thanks,
--
Ming Lei
