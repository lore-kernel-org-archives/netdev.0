From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend fails in system sleep
Date: Tue, 05 Mar 2013 18:35:31 +0100
Message-ID: <87sj49oil8.fsf@nemi.mork.no>
References: <Pine.LNX.4.44L0.1303051147300.1308-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>, Oliver Neukum <oneukum@suse.de>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<linux-input@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34709 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832Ab3CERhL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 12:37:11 -0500
In-Reply-To: <Pine.LNX.4.44L0.1303051147300.1308-100000@iolanthe.rowland.org>
	(Alan Stern's message of "Tue, 5 Mar 2013 11:54:21 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Stern <stern@rowland.harvard.edu> writes:
> On Tue, 5 Mar 2013, Bj=C3=B8rn Mork wrote:
>> Ming Lei <ming.lei@canonical.com> writes:
>>=20
>> > Yes, USB core will flush any outstanding URBs, but the driver stil=
l need
>> > to deal with suspend failure carefully, for example, suppose usb_r=
esume()
>> > is called in suspend failure path, and the submitted URBs are kill=
ed
>> > by USB core later. But after the device is wakeup, and the resume(=
) will
>> > do nothing since the suspend count is leaked. So it is what the pa=
tches
>> > are fixing, and it is better to not depend on the default flushing=
 URBs of
>> > USB core.
>>=20
>> I am starting to wonder why the USB core has combined system suspend=
 and
>> runtime suspend if we are going to end up with every driver testing
>> PMSG_IS_AUTO(message) and selecting a completely different code path=
=2E
>
> Mainly for historical reasons.  System suspend existed long before=20
> runtime suspend did.  When runtime suspend was added, it piggybacked=20
> off the existing code.  Furthermore, originally there was no=20
> requirement that system suspend always succeed; that was added later.
>
> Also, the code paths are not completely different.  They differ mainl=
y=20
> in their error handling.  But when you think about it, how serious an=
=20
> error can you encounter when you try to _stop_ using a device?

Thanks for explaining.

>> You are right that we will end up with problems if usbnet_resume is
>> called for a device usbnet hasn't suspended.  But I'd still claim th=
at
>> is a bug in the USB core, which is the one that decided to ignore th=
e
>> suspend error and still call resume.
>>=20
>> I guess proper error handling here require the USB core to see the
>> interface driver as dead if it fails to suspend on system suspend, a=
nd
>> do forced rebinding on resume.
>
> You are welcome to submit a patch to do this.  It shouldn't be hard; =
we
> already have a flag indicating that an interface needs to be unbound =
at
> reprobed at resume time.  You can update the kerneldoc in addition; a=
s
> you noticed, it currently does not describe the actual code completel=
y
> accurately.

I guess I saw that coming :)  Will take a shot at it when time permits.


Bj=C3=B8rn
